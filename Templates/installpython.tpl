#!/bin/bash
# Bootstrap Python 3.9 for Ansible compatibility

# Install Python 3.9
# sudo yum install -y python3.9 python3.9-pip not required anymore because upgraded amazon linux version to 2023

# Set Python 3.9 as the default python3
sudo alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 1
sudo alternatives --set python3 /usr/bin/python3.9

# install boto3 as compatibility for Ansible AWS modules
# Amazon linux 2023 uses dnf instead of yum
sudo dnf install -y python3-pip
sudo python3 -m pip install boto3 botocore

# Verify installation
python3 --version

echo "Boto3 installed:"
python3 -m pip show boto3 | grep version