# !/usr/bin/env bash
# set -euo pipefail
# Simple deploy script for the portfolio static site (porotofilo8/)
# Usage (on the VPS):
# 1) Edit DOMAIN variable below or pass DOMAIN env var: DOMAIN=example.com sudo bash deploy_portfolio.sh
# 2) Run as root or a user with sudo privileges.

REPO="https://github.com/Bekmuhammad-Devoloper/Partfolio.git"
BRANCH="main"
TMPDIR="/tmp/portfolio_deploy_$$"
APP_DIR="/var/www/portfolio"
DOMAIN="bekmuhammad.uz" # default to your domain; you can override by passing DOMAIN_ENV

if [ -n "${DOMAIN_ENV:-}" ]; then
  DOMAIN="$DOMAIN_ENV"
fi

echo "Deploying portfolio from $REPO (branch $BRANCH) to $APP_DIR"

# Install prerequisites
apt update
apt install -y git nginx certbot python3-certbot-nginx rsync

# Prepare dirs
rm -rf "$TMPDIR"
mkdir -p "$TMPDIR"
mkdir -p "$APP_DIR"

# Clone repo
git clone --depth 1 --branch "$BRANCH" "$REPO" "$TMPDIR"

# Copy static site files (porotofilo8/) to APP_DIR
if [ ! -d "$TMPDIR/porotofilo8" ]; then
  echo "Error: porotofilo8/ directory not found in repo"
  exit 1
fi

rsync -a --delete "$TMPDIR/porotofilo8/" "$APP_DIR/"

# Set ownership
chown -R www-data:www-data "$APP_DIR"
chmod -R 755 "$APP_DIR"

# Create nginx site config
NGINX_CONF="/etc/nginx/sites-available/portfolio"
cat > "$NGINX_CONF" <<EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;

    root $APP_DIR;
    index index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~* \.(?:manifest|appcache|html?|xml|json)$ {
        add_header Cache-Control "no-cache, no-store, must-revalidate";
    }

    location ~* \.(?:css|js|svg|png|jpg|jpeg|gif|ico|webp)$ {
        add_header Cache-Control "public, max-age=31536000, immutable";
    }
}
EOF

ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/portfolio
nginx -t && systemctl reload nginx

echo "Nginx site created and reloaded. If DNS points to this server, obtaining TLS cert with Certbot..."

if [ "$DOMAIN" = "yourdomain.com" ]; then
  echo "DOMAIN is placeholder. Edit deploy_portfolio.sh and set DOMAIN or run with DOMAIN_ENV=<yourdomain> ./deploy_portfolio.sh to obtain TLS."
else
  certbot --nginx -n --agree-tos --redirect -m admin@$DOMAIN -d "$DOMAIN" -d "www.$DOMAIN" || echo "Certbot failed or DNS not ready yet. You can run certbot manually later."
fi

echo "Cleaning up"
rm -rf "$TMPDIR"

echo "Deployment finished. Site root: $APP_DIR"

#!/usr/bin/env bash
set -euo pipefail
# Simple deploy script for the portfolio static site (porotofilo8/)
# Usage (on the VPS):
# 1) Edit DOMAIN variable below or pass DOMAIN env var: DOMAIN=example.com sudo bash deploy_portfolio.sh
# 2) Run as root or a user with sudo privileges.

REPO="https://github.com/Bekmuhammad-Devoloper/Partfolio.git"
BRANCH="main"
TMPDIR="/tmp/portfolio_deploy_$$"
APP_DIR="/var/www/portfolio"
DOMAIN="yourdomain.com" # <<< REPLACE this with your domain or pass env var

if [ -n "${DOMAIN_ENV:-}" ]; then
  DOMAIN="$DOMAIN_ENV"
fi

echo "Deploying portfolio from $REPO (branch $BRANCH) to $APP_DIR"

# Install prerequisites
apt update
apt install -y git nginx certbot python3-certbot-nginx rsync

# Prepare dirs
rm -rf "$TMPDIR"
mkdir -p "$TMPDIR"
mkdir -p "$APP_DIR"

# Clone repo
git clone --depth 1 --branch "$BRANCH" "$REPO" "$TMPDIR"

# Copy static site files (porotofilo8/) to APP_DIR
if [ ! -d "$TMPDIR/porotofilo8" ]; then
  echo "Error: porotofilo8/ directory not found in repo"
  exit 1
fi

rsync -a --delete "$TMPDIR/porotofilo8/" "$APP_DIR/"

# Set ownership
chown -R www-data:www-data "$APP_DIR"
chmod -R 755 "$APP_DIR"

# Create nginx site config
NGINX_CONF="/etc/nginx/sites-available/portfolio"
cat > "$NGINX_CONF" <<EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;

    root $APP_DIR;
    index index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~* \.(?:manifest|appcache|html?|xml|json)$ {
        add_header Cache-Control "no-cache, no-store, must-revalidate";
    }

    location ~* \.(?:css|js|svg|png|jpg|jpeg|gif|ico|webp)$ {
        add_header Cache-Control "public, max-age=31536000, immutable";
    }
}
EOF

ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/portfolio
nginx -t && systemctl reload nginx

echo "Nginx site created and reloaded. If DNS points to this server, obtaining TLS cert with Certbot..."

if [ "$DOMAIN" = "yourdomain.com" ]; then
  echo "DOMAIN is placeholder. Edit deploy_portfolio.sh and set DOMAIN or run with DOMAIN_ENV=<yourdomain> ./deploy_portfolio.sh to obtain TLS."
else
  certbot --nginx -n --agree-tos --redirect -m admin@$DOMAIN -d "$DOMAIN" -d "www.$DOMAIN" || echo "Certbot failed or DNS not ready yet. You can run certbot manually later."
fi

echo "Cleaning up"
rm -rf "$TMPDIR"

echo "Deployment finished. Site root: $APP_DIR"
