# An IAM policy and role allowing describing EC2 instances and creating tags.
# Lambda uses this to copy tags from auto scaled EC2 instances to EBS volumes.

resource "aws_iam_role" "lambda_asg_role" {
  name_prefix = "example-asg-lambda"
  description = "Role for Lambda to describe EC2 instances and create tabs"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowLambda",
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_asg_policy" {
  name_prefix = "example-asg-lambda"
  role        = "${aws_iam_role.lambda_asg_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:CreateTags"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
