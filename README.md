# AWS Auto Scaling Group EBS Tagging

EC2 instances created by an auto scaling group can be tagged, but the Elastic Block Store (EBS) volumes do not inherit those tags. This repository contains multiple solutions for tagging EBS volumes attached to auto scaled EC2 instances. Each solution includes [Terraform](http://terraform.io) code to create an AWS launch configuration and auto scaling group to demonstrate the solution.

* Use [user data](user-data/README.md) running in auto scaled EC2 instances to tag EBS volumes.
* Use [a Lambda function](lambda/README.md) to tag EBS volumes of new auto scaled EC2 instances.
