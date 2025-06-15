#!/bin/bash

yum update -y
amazon-linux-extras enable nginx1 docker
yum install -y nginx docker python3 python3-pip
pip3 install certbot certbot-nginx

systemctl enable --now nginx
systemctl enable --now docker
usermod -aG docker ec2-user

# --- Install Docker Compose v2 ---
curl -SL https://github.com/docker/compose/releases/download/v2.37.1/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# --- Create docker-compose.yml ---
mkdir -p /opt/keycloak
cat > /opt/keycloak/docker-compose.yml <<EOF
version: '3.8'

services:
  postgres:
    image: postgres:15
    container_name: keycloak-postgres
    restart: unless-stopped
    environment:
      POSTGRES_DB: keycloak
      POSTGRES_USER: keycloak
      POSTGRES_PASSWORD: secret
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - keycloak-net

  keycloak:
    image: quay.io/keycloak/keycloak:24.0.3
    container_name: keycloak
    restart: unless-stopped
    command:
      - start-dev
    environment:
      KC_DB: postgres
      KC_DB_URL: jdbc:postgresql://keycloak-postgres:5432/keycloak
      KC_DB_USERNAME: keycloak
      KC_DB_PASSWORD: secret
      KC_FEATURES: token-exchange,admin-fine-grained-authz
      KC_HOSTNAME: ${domain}
      KC_HTTP_ENABLED: "true"
      KC_PROXY_HEADERS: xforwarded
      KC_HOSTNAME_STRICT: "false"
      KEYCLOAK_ADMIN: admin
      KEYCLOAK_ADMIN_PASSWORD: your_admin_password_here
    ports:
      - "8080:8080"
    depends_on:
      - postgres
    networks:
      - keycloak-net

volumes:
  postgres_data:

networks:
  keycloak-net:
EOF

# --- Start Keycloak ---
cd /opt/keycloak
docker-compose up -d

# --- Nginx reverse proxy ---
cat > /etc/nginx/conf.d/keycloak.conf <<EOL
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

nginx -s reload

# --- Wait for Keycloak to be ready (simple wait) ---
echo "Waiting for Keycloak to start..."
sleep 30

# shellcheck disable=SC2154
sudo certbot --nginx -d "${domain}" --non-interactive --agree-tos -m "${email}"
