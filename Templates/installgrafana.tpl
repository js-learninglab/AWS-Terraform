#!/bin/bash
# install_grafana.sh

# fetch prometheus from github
LATEST_VERSION=$(curl -s https://api.github.com/repos/grafana/grafana/releases/latest | grep tag_name | cut -d '"' -f 4)
TAR_FILE="prometheus-${LATEST_VERSION}.linux-amd64.tar.gz"

cd /tmp/
curl -LO https://github.com/grafana/grafana/releases/download/${LATEST_VERSION}/${TAR_FILE}
tar xvf ${TAR_FILE}
cd prometheus-${LATEST_VERSION}.linux-amd64/

# configure binaries directories
sudo mv grafana /usr/local/bin/
sudo mv promtool /usr/local/bin/

# create configuration and data directories
sudo mkdir -p /etc/grafana /var/lib/grafana

# create separate user account and unable to login interactively :D haha
sudo useradd --no-create-home --shell /bin/false prometheus

# move config files
sudo mv consoles/ /etc/grafana/
sudo mv console_libraries/ /etc/grafana
sudo mv grafana.yml /etc/grafana/grafana.yml

# give ownership of directories to the account
sudo chown -R grafana:prometheus /etc/grafana
sudo chown -R grafana:prometheus /var/lib/grafana
sudo chown grafana:prometheus /usr/local/bin/grafana
sudo chown grafana:prometheus /usr/local/bin/promtool

# create systemd service file
sudo tee /etc/systemd/system/grafana.service > /dev/null <<EOF
[Unit]
Description=Grafana
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/grafana \
  --config.file=/etc/grafana/grafana.yml \
  --storage.tsdb.path=/var/lib/grafana/ \
  --web.console.templates=/etc/grafana/consoles \
  --web.console.libraries=/etc/grafana/console_libraries

[Install]
WantedBy=multi-user.target
EOF

# restart service
sudo systemctl daemon-reload
sudo systemctl start grafana
sudo systemctl enable grafana