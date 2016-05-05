#!/bin/bash

#==============================================================
# This scripts retrieves the Ansible vault encryption key
# It sends the key value to the sandard output
#==============================================================

# Configuration
bucket_location=${MNO_DEPLOY_BUCKET}${MNO_DEPLOY_PATH}

# Download AWS CLI
pip install awscli > /dev/null 

# Upload package to S3
aws s3 cp s3://$bucket_location/key.txt ./key.txt > /dev/null 

# Output the key
cat ./key.txt

# Delete the key
rm -rf ./key.txt > /dev/null 
