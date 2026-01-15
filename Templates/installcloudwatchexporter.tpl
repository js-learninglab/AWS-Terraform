#!/bin/bash

# install java as prerequisite
sudo dnf install -y java-17-amazon-corretto

# fetch cloudwatch exporter from github (similar like prometheus installer?)
# define version
VERSION="0.16.0"

# define filename
JAR_FILE="cloudwatch_exporter-${VERSION}-jar-with-dependencies.jar"

cd /tmp/
curl -LO https://github.com/prometheus/cloudwatch_exporter/releases/download/v${VERSION}/cloudwatch_exporter-${VERSION}-jar-with-dependencies.jar

# move jar file to another location
sudo mv ${JAR_FILE} /opt/cloudwatch_exporter.jar

# SIMILAR TO PROMETHEUS file!!! need further config
# create config file
sudo mkdir -p /etc/cloudwatch_exporter

sudo tee /etc/cloudwatch_exporter/config.yml > /dev/null <<EOF
region: us-west-2
metrics:
  - aws_namespace: AWS/RDS
    aws_metric_name: CPUUtilization
    aws_dimensions: [DBInstanceIdentifier]
    
  - aws_namespace: AWS/RDS
    aws_metric_name: DatabaseConnections
    aws_dimensions: [DBInstanceIdentifier]
    
  - aws_namespace: AWS/RDS
    aws_metric_name: FreeableMemory
    aws_dimensions: [DBInstanceIdentifier]
    
  - aws_namespace: AWS/RDS
    aws_metric_name: FreeStorageSpace
    aws_dimensions: [DBInstanceIdentifier]
EOF

# create systemd service file
sudo tee /etc/systemd/system/cloudwatch-exporter.service > /dev/null <<EOF
[Unit]
Description=CloudWatch Exporter
After=network.target

[Service]
Type=simple
User=nobody
ExecStart=/usr/bin/java -jar /opt/cloudwatch_exporter.jar 9106 /etc/cloudwatch_exporter/config.yml
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# restart service
sudo systemctl daemon-reload
sudo systemctl start cloudwatch-exporter
sudo systemctl enable cloudwatch-exporter