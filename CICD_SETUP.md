# CI/CD Setup Guide

## GitHub Actions bilan avtomatik deploy

Har safar `main` branchga push qilganingizda portfolio avtomatik VPS'ga deploy bo'ladi.

## Setup qadamlari

### 1. GitHub Secrets sozlash

GitHub repository → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

Quyidagi secretlarni qo'shing:

| Secret nomi | Qiymati |
|-------------|---------|
| `VPS_HOST` | `138.249.7.151` |
| `VPS_USERNAME` | `root` |
| `VPS_PORT` | `22` |
| `VPS_SSH_KEY` | VPS SSH private key (pastda ko'rsatilgan) |

### 2. SSH Key yaratish (agar yo'q bo'lsa)

**Lokal kompyuterda:**
```bash
ssh-keygen -t ed25519 -C "github-actions-deploy" -f ~/.ssh/github_deploy
```

**Public keyni VPS'ga qo'shish:**
```bash
# VPS'da
cat >> ~/.ssh/authorized_keys << 'EOF'
<PUBLIC_KEY_CONTENT>
EOF
```

**Private keyni GitHub secretga qo'shish:**
- `~/.ssh/github_deploy` faylining to'liq mazmunini `VPS_SSH_KEY` secretga qo'ying
- `-----BEGIN OPENSSH PRIVATE KEY-----` dan `-----END OPENSSH PRIVATE KEY-----` gacha

### 3. Test qilish

```bash
# Lokal o'zgartirish qiling
git add .
git commit -m "Test CI/CD"
git push origin main
```

GitHub → **Actions** tabida workflow ishlayotganini ko'ring.

## Workflow tushuntirishi

```yaml
on:
  push:
    branches: [main]
    paths:
      - 'porotofilo8/**'      # Faqat portfolio fayllar o'zgarganda
      - '.github/workflows/**' # yoki workflow o'zgarganda
```

- Faqat `main` branchga push qilganda ishlaydi
- Faqat `porotofilo8/` papkasidagi fayllar o'zgarganda ishlaydi
- Boshqa fayllar (README, etc.) o'zgarganda ishlamaydi — resursni tejaydi

## Manual deploy (agar kerak bo'lsa)

GitHub → **Actions** → **Deploy Portfolio to VPS** → **Run workflow**

## Troubleshooting

### Workflow ishlamayapti
1. **Actions** tabida xatolikni tekshiring
2. Secretlar to'g'ri kiritilganini tekshiring
3. SSH key formatini tekshiring (OpenSSH format bo'lishi kerak)

### SSH ulanish xatosi
```bash
# VPS'da SSH daemon holatini tekshiring
systemctl status sshd

# Firewall tekshiring
ufw status
ufw allow 22
```

### Permission denied
```bash
# VPS'da authorized_keys huquqlarini tekshiring
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

## Foydalanish

Endi har safar portfolio fayllarini o'zgartirib push qilganingizda:

1. GitHub Actions avtomatik ishga tushadi
2. VPS'ga SSH orqali ulanadi
3. Yangi fayllarni `/var/www/portfolio/` ga ko'chiradi
4. Nginx reload qiladi
5. Sayt yangilanadi!

**Natija:** https://bekmuhammad.uz avtomatik yangilanadi 🚀
