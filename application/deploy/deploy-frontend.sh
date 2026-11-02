#!/bin/bash
set -euo pipefail

BACKEND_ALB="${1:-}"
FRONTEND_SOURCE="${2:-$(pwd)/frontend}"

if [ -z "$BACKEND_ALB" ]; then
  echo 'Usage: sudo bash deploy-frontend.sh "http://INTERNAL-BACKEND-ALB-DNS" [/path/to/frontend]'
  exit 1
fi

if [ ! -f "$FRONTEND_SOURCE/index.html" ]; then
  echo "Frontend index.html not found in $FRONTEND_SOURCE"
  exit 1
fi

dnf install -y nginx
install -d /usr/share/nginx/html
install -m 0644 "$FRONTEND_SOURCE/index.html" /usr/share/nginx/html/index.html

cat > /etc/nginx/conf.d/three-tier-app.conf <<EOF
server {
    listen 80 default_server;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files \\$uri \\$uri/ /index.html;
    }

    location /api/ {
        proxy_pass ${BACKEND_ALB}/api/;
        proxy_http_version 1.1;
        proxy_set_header Host \\$host;
        proxy_set_header X-Real-IP \\$remote_addr;
    }
}
EOF

nginx -t
systemctl enable --now nginx
systemctl restart nginx
