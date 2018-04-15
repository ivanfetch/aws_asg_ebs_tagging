#!/bin/bash
# Get tags from the EC2 instance,
# and assign them to attached EBS volumes.
#
# Install required packages.
# This assumes Amazon Linux:
yum install -y aws-cli jq curl

echo Getting availability zone, region, and instance id...
EC2_AVAIL_ZONE=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
EC2_REGION=`echo "${EC2_AVAIL_ZONE:0:${#EC2_AVAIL_ZONE}-1}"`
EC2_INST_ID=`curl -s http://169.254.169.254/latest/meta-data/instance-id`

echo Getting tags from this EC2 instance: ${EC2_INST_ID}
# The below jq command creates JSON usable by
# the aws ec2 create-tags command.
inst_tags_json=$(aws ec2 describe-tags --region ${EC2_REGION} --output json --filters Name=resource-id,Values=${EC2_INST_ID} | \
jq '{ Tags: [ .Tags[] | select(.Key | test("^aws:"; "i") | not ) | {Key: .Key  , Value: .Value} ] } ')

echo Getting volumes attached to this EC2 instance. . .
all_volume_ids=$(aws ec2 describe-volumes \
--region ${EC2_REGION} \
--output text \
--filters Name=attachment.instance-id,Values=$EC2_INST_ID \
--query 'Volumes[*].VolumeId')

echo "Tagging volumes $all_volume_ids with these tags: ${inst_tags_json}"
aws ec2 create-tags --region ${EC2_REGION} \
--resources $all_volume_ids \
--cli-input-json "${inst_tags_json}"

