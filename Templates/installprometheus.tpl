#!/bin/bash
# install_prometheus.sh

# fetch prometheus from github
LATEST_VERSION=$(curl -s https://api.github.com/repos/prometheus/prometheus/releases/latest | grep tag_name | cut -d '"' -f 4)
TAR_FILE="prometheus-${LATEST_VERSION}.linux-amd64.tar.gz"

cd /tmp/
curl -LO https://github.com/prometheus/prometheus/releases/download/${LATEST_VERSION}/${TAR_FILE}
tar xvf ${TAR_FILE}
cd prometheus-${LATEST_VERSION}.linux-amd64/

# configure binaries directories
sudo mv prometheus /usr/local/bin/
sudo mv promtool /usr/local/bin/

# create configuration and data directories
sudo mkdir -p /etc/prometheus /var/lib/prometheus

# create separate user account and unable to login interactively :D haha
sudo useradd --no-create-home --shell /bin/false prometheus

# move config files
sudo mv consoles/ /etc/prometheus/
sudo mv console_libraries/ /etc/prometheus
sudo mv prometheus.yml /etc/prometheus/prometheus.yml

# give ownership of directories to the account
sudo chown -R prometheus:prometheus /etc/prometheus
sudo chown -R prometheus:prometheus /var/lib/prometheus
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool

# create systemd service file
sudo tee /etc/systemd/system/prometheus.service > /dev/null <<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus/ \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

# restart service
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus