#!/bin/bash

set -x

# Fetch a list of all available Amazon Linux AMIs
aws ec2 describe-images \
  --region eu-central-1 \
	--filters \
		Name=owner-alias,Values=amazon \
		Name=name,Values="amzn-ami-hvm-*" \
		Name=virtualization-type,Values=hvm \
		Name=root-device-type,Values=ebs \
		Name=block-device-mapping.volume-type,Values=gp2 \
  --query 'Images' \
  --output json
