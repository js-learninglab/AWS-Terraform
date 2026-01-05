#!/bin/bash
# install_grafana.sh

# Create repo file
sudo tee /etc/yum.repos.d/grafana.repo > /dev/null <<EOF
[grafana]
name=grafana
baseurl=https://packages.grafana.com/oss/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packages.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOF

# install grafana
sudo yum install -y grafana

# start and enable grafana service
sudo systemctl start grafana-server
sudo systemctl enable grafana-server

