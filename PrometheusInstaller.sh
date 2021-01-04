#!/bin/bash
export RELEASE="2.23.0"

wget https://github.com/prometheus/prometheus/releases/download/v${RELEASE}/prometheus-${RELEASE}.linux-amd64.tar.gz
echo "Done Downloding"
tar xvf prometheus-${RELEASE}.linux-amd64.tar.gz
echo "done extracting"
cd prometheus-${RELEASE}.linux-amd64/
echo " inside prometheus directory"
groupadd --system prometheus
useradd -s /sbin/nologin -r -g prometheus prometheus
mkdir -p /etc/prometheus/{rules,rules.d,files_sd}  /var/lib/prometheus
cp prometheus promtool /usr/local/bin/
echo " promethus moved from /usr/locl/bin/"
cp -r consoles/ console_libraries/ /etc/prometheus/
echo '[Unit]
Description=Prometheus systemd service unit
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/bin/bash /usr/local/bin/prometheus \
--config.file=/etc/prometheus/prometheus.yml \
--storage.tsdb.path=/var/lib/prometheus \
--web.console.templates=/etc/prometheus/consoles \
--web.console.libraries=/etc/prometheus/console_libraries \
--web.listen-address=0.0.0.0:9090

SyslogIdentifier=prometheus
Restart=always

[Install]
WantedBy=multi-user.target' > /etc/systemd/system/prometheus.service
echo "# Global config
global: 
 scrape_interval: 15s # Set the scrape interval to every 15 seconds.
 evaluation_interval: 15s # Evaluate rules every 15 seconds. 
 scrape_timeout: 15s # scrape_timeout is set to the global default (10s).

# A scrape configuration containing exactly one endpoint to scrape:# Here it's Prometheus itself.
scrape_configs:
 # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
 - job_name: 'prometheus'

# metrics_path defaults to '/metrics'
 # scheme defaults to 'http'.

static_configs:
 - targets: ['localhost:9090']">/etc/prometheus/prometheus.yml
chown -R prometheus:prometheus /etc/prometheus/  /var/lib/prometheus/
chmod -R 775 /etc/prometheus/ /var/lib/prometheus/

echo 'instalation completed'
