# An IAM policy, role, and instance profile allowing describing tags,
# describing volumes, and creating tags.
# Userdata uses this to copy tags from auto scaled EC2 instances to EBS volumes.

resource "aws_iam_role" "ec2_asg_role" {
  name_prefix = "example-asg-userdata"
  description = "Role for auto-scaling EC2 instances to get tags from EC2, describe volumes, and add tags to volumes."

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowEC2",
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ec2_asg_policy" {
  name_prefix = "example-asg-userdata"
  role        = "${aws_iam_role.ec2_asg_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeTags",
"ec2:DescribeVolumes",
"ec2:CreateTags"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ec2_asg_profile" {
  name_prefix = "example-asg-userdata"
  role        = "${aws_iam_role.ec2_asg_role.name}"
}

output "instance_profile_name" {
  description = "The IAM instance profile name"
  value       = "${aws_iam_instance_profile.ec2_asg_profile.name}"
}
