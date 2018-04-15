# Example Launch Configuration and Auto Scaling Group,
# which relies on a lambda function to tag EBS volumes.
# THis uses the Terraform `autoscaling` module from the registry,
# available at: https://registry.terraform.io/modules/terraform-aws-modules/autoscaling/aws/2.2.1

##############################################################
# Data sources to get VPC, subnets and security group details
##############################################################
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = "${data.aws_vpc.default.id}"
}

data "aws_security_group" "default" {
  vpc_id = "${data.aws_vpc.default.id}"
  name   = "default"
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}

######
# Launch configuration and autoscaling group
######
module "example-lambda" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "2.2.1"

  name = "example-asg-lambda"

  lc_name = "example-asg-lambda-lc"

  user_data = <<EOF
# Tagging EBS volumes happens via a lambda function.
EOF

  image_id      = "${data.aws_ami.amazon_linux.id}"
  instance_type = "t2.micro"

    security_groups             = ["${data.aws_security_group.default.id}"]
  # Alternatively you may want to include a security group of your own,
  # if you don't have another instance also in the default security group,
  # and you want to be able to connect to instances created by the auto scaling group.
  #security_groups = ["${data.aws_security_group.default.id}", "sg-8997c3ee"]

  # IF you want to be able to SSH into EC2 instances created by the auto scaling group,
  # Set a key name here.
  #key_name = "ifetch"

  associate_public_ip_address = true

  root_block_device = [
    {
      volume_size           = "10"
      volume_type           = "gp2"
      delete_on_termination = true
    },
  ]

  ebs_block_device = [
    {
      device_name           = "/dev/xvdz"
      volume_type           = "gp2"
      volume_size           = "5"
      delete_on_termination = true
    },
  ]

  # Auto scaling group
  asg_name                  = "example-asg-lambda-asg"
  vpc_zone_identifier       = ["${data.aws_subnet_ids.all.ids}"]
  health_check_type         = "EC2"
  min_size                  = 0
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0

  # These tags will also be propagated to EBS volumes by the user-data.
  tags = [
    {
      key                 = "Environment"
      value               = "dev"
      propagate_at_launch = true
    },
    {
      key                 = "Name"
      value               = "example-lambda-asg-ec2"
      propagate_at_launch = true
    },
  ]

  # Another way to specify tags, provided by the `autoscaling` Terraform module.
  tags_as_map = {
    billing_department = "marketing"
  }
}

# Outputs for Launch Configuration and Auto Scaling Group IDs
output "launch_configuration_id" {
  description = "The ID of the launch configuration"
  value       = "${module.example-lambda.this_launch_configuration_id}"
}

output "autoscaling_group_id" {
  description = "The autoscaling group id"
  value       = "${module.example-lambda.this_autoscaling_group_id}"
}
