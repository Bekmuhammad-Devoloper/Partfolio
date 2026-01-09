# Deploy Portfolio (Static site) — quick guide

This repository contains the portfolio source in `porotofilo8/`. The easiest production setup is to serve the built static files via Nginx. The repo now includes `deploy_portfolio.sh` which automates cloning, copying files to `/var/www/portfolio`, creating an Nginx config, and (optionally) requesting a cert with Certbot.

Files added:
- `deploy_portfolio.sh` — copy/paste script to run on the VPS (needs sudo/root)
- `nginx/portfolio.conf` — nginx config template (also used by the script)

Quick manual steps (if you prefer to do commands yourself):

1) SSH to your VPS

```bash
ssh youruser@your.vps.ip
```

2) Copy the script to the VPS (if you prefer not to clone the repo on the VPS):

```bash
# from your local machine
scp deploy_portfolio.sh youruser@your.vps.ip:/tmp/
ssh youruser@your.vps.ip
sudo bash /tmp/deploy_portfolio.sh
```

3) Or run directly from the repo (recommended):

```bash
# Run on the VPS as sudo (set domain first):
DOMAIN=yourdomain.com sudo bash ./deploy_portfolio.sh
```

Notes:
- Replace `yourdomain.com` with your real domain before running the script, or run `sudo DOMAIN=yourdomain.com bash deploy_portfolio.sh`.
- The script clones `https://github.com/Bekmuhammad-Devoloper/Partfolio.git` and copies `porotofilo8/` contents into `/var/www/portfolio`.
- If you don't want Certbot to run automatically, set DOMAIN to `yourdomain.com` (placeholder) and run certbot manually later.
- The script uses `www-data` as the file owner so Nginx can serve files.

After the script completes:
- Visit http://yourdomain.com (if DNS already points to the VPS IP) to verify.
- If certificate was requested, HTTPS will be enabled automatically.

If you'd like, I can also:
- Make the site available under the root domain plus `www` with redirects (script already requests cert with redirect when domain provided).
- Add a small systemd or cron job to automatically pull updates from the repo and rsync files (zero-downtime deploys) — tell me if you want an automated update script.
