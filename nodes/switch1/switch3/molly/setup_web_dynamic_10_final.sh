#!/bin/bash

set -e

DOMAIN="core.k22.com"
WEBROOT="/var/www/core"

echo "======================================"
echo " WEB DYNAMIC - SOAL 10 FINAL"
echo "======================================"
echo
echo "Node     : $(hostname)"
echo "Domain   : $DOMAIN"
echo

# ============================================================
# 1. INSTALL PACKAGE
# ============================================================

echo "[1/8] Installing Nginx + PHP-FPM..."

apt-get update
apt-get install -y nginx php8.4-fpm php-cli

# ============================================================
# 2. START PHP-FPM
# ============================================================

echo
echo "[2/8] Starting PHP-FPM..."

PHP_FPM_BIN="/usr/sbin/php-fpm8.4"

if [ ! -x "$PHP_FPM_BIN" ]; then
    echo "ERROR: $PHP_FPM_BIN tidak ditemukan."
    echo
    dpkg -L php8.4-fpm | grep '/usr/sbin/' || true
    exit 1
fi

if ! pgrep -x "php-fpm8.4" >/dev/null 2>&1; then
    "$PHP_FPM_BIN" -D
fi

sleep 1

echo
echo "PHP-FPM process:"
pgrep -a "php-fpm8.4" || true

# ============================================================
# 3. DETECT SOCKET
# ============================================================

echo
echo "[3/8] Detecting PHP-FPM socket..."

PHP_SOCKET=$(find /run/php \
    -maxdepth 1 \
    -type s \
    -name 'php*-fpm.sock' \
    | head -n 1)

if [ -z "$PHP_SOCKET" ]; then
    echo "ERROR: PHP-FPM socket tidak ditemukan."
    echo
    echo "Isi /run/php:"
    ls -lah /run/php/ || true
    exit 1
fi

echo "PHP-FPM socket:"
echo "  $PHP_SOCKET"

# ============================================================
# 4. CREATE WEB APPLICATION
# ============================================================

echo
echo "[4/8] Creating PHP application..."

mkdir -p "$WEBROOT"

cat > "$WEBROOT/index.php" <<'EOF'
<?php
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Core Web</title>
</head>
<body>

<h1>Core Dynamic Web</h1>

<p>Hostname: <?php echo gethostname(); ?></p>

<p>Server: Nginx + PHP-FPM</p>

<p>
    <a href="/profil">Lihat Profil</a>
</p>

</body>
</html>
EOF

cat > "$WEBROOT/profil.php" <<'EOF'
<?php
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Profil - Core Web</title>
</head>
<body>

<h1>Halaman Profil</h1>

<p>Ini adalah halaman profil dari core.k22.com.</p>

<p>Hostname: <?php echo gethostname(); ?></p>

<p>
    <a href="/">Kembali ke Beranda</a>
</p>

</body>
</html>
EOF

# ============================================================
# 5. CLEAN OLD NGINX CONFIG
# ============================================================

echo
echo "[5/8] Cleaning old Nginx configuration..."

# Hapus konfigurasi lama yang kita buat sebelumnya
rm -f /etc/nginx/sites-enabled/core
rm -f /etc/nginx/sites-enabled/core.k22.com

rm -f /etc/nginx/sites-available/core
rm -f /etc/nginx/sites-available/core.k22.com

# Pastikan default tidak mengambil alih
rm -f /etc/nginx/sites-enabled/default

# ============================================================
# 6. CREATE NGINX CONFIG
# ============================================================

echo
echo "[6/8] Configuring Nginx..."

cat > /etc/nginx/sites-available/core.k22.com <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    root $WEBROOT;
    index index.php index.html;

    # Homepage
    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    # Clean URL:
    # /profil -> /profil.php
    location = /profil {
        rewrite ^/profil\$ /profil.php last;
    }

    # PHP-FPM
    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:$PHP_SOCKET;
    }
}
EOF

ln -sf \
    /etc/nginx/sites-available/core.k22.com \
    /etc/nginx/sites-enabled/core.k22.com

# ============================================================
# 7. TEST & START NGINX
# ============================================================

echo
echo "[7/8] Testing Nginx configuration..."

nginx -t

echo
echo "[8/8] Starting / reloading Nginx..."

if pgrep -x nginx >/dev/null 2>&1; then
    nginx -s reload
else
    nginx
fi

sleep 1

# ============================================================
# DONE
# ============================================================

echo
echo "======================================"
echo " WEB DYNAMIC - SOAL 10 READY"
echo "======================================"
echo
echo "Node:"
echo "  $(hostname)"
echo
echo "Domain:"
echo "  $DOMAIN"
echo
echo "Webroot:"
echo "  $WEBROOT"
echo
echo "PHP-FPM:"
echo "  $PHP_FPM_BIN"
echo
echo "Socket:"
echo "  $PHP_SOCKET"
echo
echo "Nginx:"
pgrep -a nginx || true
echo
echo "PHP-FPM:"
pgrep -a php-fpm8.4 || true
echo
echo "======================================"
echo " TEST"
echo "======================================"
echo
echo "curl http://core.k22.com/"
echo "curl http://core.k22.com/profil"
echo