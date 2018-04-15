#
# Tag EBS volumes attached to the EC2 instance specified in a Lambda event.
# This function should be called from a CloudWatch event, triggered when a new EC2 instance is created by an auto scaling group.
#
# This copies all tags from the EC2, to all attached EBS volumes.
# Tags which start with `AWS:` are excluded, as those can only be created by AWS services.

import boto3
import os
import re
from time import sleep

ec2 = boto3.client('ec2')

def lambda_handler(event, _context):
    instance_id = event['detail']['EC2InstanceId']
    # Wait for the EC2 instance to be tagged, and for EBS volumes to be attached.
    sleep(5)
    # Get details about the EC2 instance whos ID was passed in the Lambda event,
    # used to get the EC2 tags and attached EVS volumes.
    instance_details = ec2.describe_instances(InstanceIds=[instance_id])['Reservations'][0]['Instances'][0]

    tags = []
    # Loop through the EC2 tags, adding all tags other than `aws:` tags to a list.
    for tag in instance_details['Tags']:
        if not re.match('^aws:', tag['Key'], re.IGNORECASE):
            tags.append(tag)

    for block in instance_details['BlockDeviceMappings']:
        volume_id = block['Ebs']['VolumeId']
        print "Creating tags on ", volume_id, "\n"
        #print tags
        ec2.create_tags(
          Resources=[volume_id],
          Tags=tags
        )
