#!/bin/bash
# Bootstrap Python 3.8 for Ansible compatibility

# Install Python 3.8
sudo amazon-linux-extras install python3.8 -y

# Set Python 3.8 as the default python3
sudo alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1
sudo alternatives --set python3 /usr/bin/python3.8

# Verify installation
python3 --version