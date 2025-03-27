#!/bin/bash

# Configuration
S3_BUCKET="awsbucketforttn"
S3_PREFIX="imagebuilder/scripts"
LOCAL_SCRIPT_DIR="./scripts"
S3_URI="s3://${S3_BUCKET}/${S3_PREFIX}"

# Optional: AWS region (you can also set it via AWS CLI profile or env vars)
AWS_REGION="us-east-1"

# Step 1: Upload the scripts directory to S3
echo "Uploading scripts directory to S3: ${S3_URI}"
aws s3 cp "${LOCAL_SCRIPT_DIR}" "${S3_URI}" --recursive --region "${AWS_REGION}"

# Output for CloudFormation template usage
echo "✅ Upload complete. Use this in your CloudFormation template:"
echo "Uri: ${S3_URI}/component.yml"
