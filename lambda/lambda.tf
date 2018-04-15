# Lambda function and CloudWatch event / rule
# to tag EBS volumes attached to autoscaled EC2 instances.

data "archive_file" "lambda_zip_file" {
  type        = "zip"
  source_dir  = "${path.root}/lambda-code"
  output_path = "${path.root}/tmp/lambda.zip"
}

resource "aws_lambda_function" "tagger" {
  function_name = "example-asg-lambda-tagger"
  runtime       = "python2.7"
  handler       = "example-asg-lambda-tagger.lambda_handler"
  role          = "${aws_iam_role.lambda_asg_role.arn}"

  # The Lamda function starts with sleep(5) to wait for EBS attachment.
  timeout          = 20
  filename         = "${path.root}/tmp/lambda.zip"
  source_code_hash = "${data.archive_file.lambda_zip_file.output_base64sha256}"
}

resource "aws_cloudwatch_event_rule" "new_asg_ec2" {
  name        = "example-asg-lambda-new-ec2"
  description = "Trigger an EBS Lambda tagging function when new ASG EC2s are created"

  event_pattern = <<EOF
{
  "source": [
    "aws.autoscaling"
  ],
  "detail-type": [
    "EC2 Instance Launch Successful"
  ]
}
EOF
}

resource "aws_cloudwatch_event_target" "cloudwatch_to_lambda" {
  rule      = "${aws_cloudwatch_event_rule.new_asg_ec2.name}"
  target_id = "example-asg-lambda-target"
  arn       = "${aws_lambda_function.tagger.arn}"
}

resource "aws_lambda_permission" "cloudwatch_run_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.tagger.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.new_asg_ec2.arn}"
}
