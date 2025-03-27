#!/bin/bash
set -e

echo "### Updating OS..."
sudo yum update -y

echo "### Running install-postgres.sh"
bash scripts/install-postgres.sh

echo "### Running install-apache.sh"
bash scripts/install-apache.sh

# Add more as needed:
# echo "### Running install-docker.sh"
# bash scripts/install-docker.sh
