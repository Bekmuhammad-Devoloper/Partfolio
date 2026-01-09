# Deploy (PM2) — quick steps for Ubuntu 20.04/22.04

This file shows a minimal, copy/paste friendly set of steps to deploy the `Hisobchi-ai` (NestJS/Node) project to a VPS using PM2 and Nginx as a reverse proxy.

Assumptions and notes
- The project repo is: https://github.com/Bekmuhammad-Devoloper/Hisobchi-ai
- The app uses `npm run build` to compile and `npm run start:prod` to run the compiled app (typical NestJS). If your project uses different scripts, update `ecosystem.config.js` accordingly.
- You will set real secrets in `.env` on the server (do not commit secrets).
- These steps target Ubuntu (22.04/20.04). Adjust package commands for other distros.

1) Server preparation (run as a user with sudo)

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git build-essential curl

# Install Node.js 18.x (adjust version if needed)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Verify
node -v && npm -v

# Install PM2 globally
sudo npm install -g pm2
```

2) Clone repo and install

```bash
# choose a deploy directory
cd /var/www || cd ~
sudo mkdir -p /var/www/hisobchi && sudo chown $USER:$USER /var/www/hisobchi
cd /var/www/hisobchi
git clone https://github.com/Bekmuhammad-Devoloper/Hisobchi-ai .

# copy example env and edit
cp .env.example .env
# EDIT .env now with your secrets (use nano/vim)
nano .env

npm install --production
npm run build
```

3) Start with PM2

```bash
# start the app using the provided ecosystem file
pm2 start /path/to/repo/ecosystem.config.js --env production

# if you edited .env and want pm2 to pick the env vars:
export $(cat .env | xargs) && pm2 start ecosystem.config.js --env production --update-env

# save the pm2 process list and enable startup on boot
pm2 save
pm2 startup systemd
# Follow the printed command from pm2 startup (it will show a command you must run as sudo)
```

4) Nginx reverse proxy and TLS (Let’s Encrypt)

```bash
sudo apt install -y nginx certbot python3-certbot-nginx

# Example Nginx site config (replace yourdomain.com)
sudo tee /etc/nginx/sites-available/hisobchi <<'NG'
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
NG

sudo ln -s /etc/nginx/sites-available/hisobchi /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx

# Obtain TLS cert (make sure DNS A record points to your VPS)
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com

# enable auto-renew (installed by certbot package)
```

5) Useful PM2 commands

```bash
pm2 status
pm2 logs hisobchi-ai --lines 200
pm2 restart hisobchi-ai
pm2 stop hisobchi-ai
pm2 delete hisobchi-ai
```

6) Notes & troubleshooting
- If your app needs a database, you'll need to provision Postgres (install on the same VPS or use managed DB) and point `DATABASE_URL` in `.env` to its connection string.
- If you prefer Docker deployment, I can provide a Dockerfile + docker-compose.yml instead.
- If PM2 doesn't pick `.env` values automatically, use `export $(cat .env | xargs)` before starting or include sensitive vars in a secure secret manager.

If you'd like, I can also create a small `deploy.sh` script to automate steps 2–3 (clone, install, build, pm2 start). Tell me if you want that.
