#!/bin/bash
set -euo pipefail

APP_SOURCE="${1:-$(pwd)/backend}"
APP_DIR="/opt/three-tier-app/backend"

if [ ! -f "$APP_SOURCE/app.js" ] || [ ! -f "$APP_SOURCE/package.json" ]; then
  echo "Usage: sudo bash deploy-backend.sh /path/to/backend"
  exit 1
fi

dnf install -y nodejs
mkdir -p "$APP_DIR"
cp "$APP_SOURCE/app.js" "$APP_SOURCE/package.json" "$APP_DIR/"

if [ ! -f "$APP_DIR/.env" ]; then
  echo "Create $APP_DIR/.env from deploy/backend.env.example and fill RDS credentials first."
  exit 1
fi

cd "$APP_DIR"
npm install --omit=dev
install -m 0644 "$(dirname "$0")/backend.service" /etc/systemd/system/three-tier-backend.service
systemctl daemon-reload
systemctl enable --now three-tier-backend
systemctl restart three-tier-backend
systemctl --no-pager --full status three-tier-backend
