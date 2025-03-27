#!/bin/bash
set -e

echo "Installing Apache..."
sudo yum update -y
sudo yum install -y httpd
sudo systemctl enable httpd
