#!/bin/bash

set -e

echo "======================================"
echo " WEB STATIC - SOAL 9"
echo "======================================"

echo "[1/5] Installing Apache..."
apt-get update
apt-get install -y apache2

echo "[2/5] Creating /arsip/ directory..."
mkdir -p /var/www/html/arsip

echo "[3/5] Creating sample files..."

cat > /var/www/html/arsip/index.txt <<EOF
ARSIP WEB STATIC
Hostname: $(hostname)
Server: Apache
Directory: /arsip/
EOF

cat > /var/www/html/arsip/dokumen.txt <<EOF
Dokumen arsip pada $(hostname)
EOF

cat > /var/www/html/arsip/info.txt <<EOF
Static web server - Soal 9
EOF

echo "[4/5] Enabling Apache autoindex..."

cat > /etc/apache2/conf-available/arsip-autoindex.conf <<'EOF'
<Directory /var/www/html/arsip>
    Options +Indexes
    AllowOverride None
    Require all granted
</Directory>
EOF

a2enconf arsip-autoindex >/dev/null

echo "[5/5] Checking and starting Apache..."

apachectl configtest

if pgrep -x apache2 >/dev/null; then
    echo "Apache sedang berjalan, melakukan restart..."
    apachectl -k restart
else
    echo "Apache belum berjalan, melakukan start..."
    apachectl -k start
fi

echo
echo "======================================"
echo " WEB STATIC - SOAL 9 READY"
echo "======================================"
echo
echo "Hostname : $(hostname)"
echo "Directory: /arsip/"
echo
echo "URL:"
echo "  http://$(hostname)/arsip/"
echo
echo "Apache process:"
pgrep -a apache2 || true
echo
echo "Directory listing:"
ls -lah /var/www/html/arsip
echo
echo "HTTP test:"
curl -I "http://127.0.0.1/arsip/"
echo