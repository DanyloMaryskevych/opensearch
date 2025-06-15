#!/bin/bash

yum update -y
amazon-linux-extras enable nginx1
yum install -y nginx
systemctl enable nginx
systemctl start nginx

# Setup nginx reverse proxy for OpenSearch Dashboards
cat > /etc/nginx/conf.d/opensearch.conf <<EOL
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;

    location / {
        proxy_pass ${endpoint};
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL

systemctl reload nginx

sudo yum install -y python3 python3-pip
sudo pip3 install certbot certbot-nginx
sudo certbot --nginx -d "${domain}" --non-interactive --agree-tos -m "${email}"
