#!/bin/bash
set -e

echo "========================================"
echo " FIX SOAL 14 - APACHE FAMILY"
echo "========================================"

# Ambil IP client asli dari X-Forwarded-For
# lalu teruskan sebagai X-Real-IP ke backend.
cat > /etc/apache2/conf-available/soal14-real-ip.conf <<'CONF'
RequestHeader set X-Real-IP "%{HTTP:X-Forwarded-For}i"
CONF

a2enmod headers
a2enconf soal14-real-ip

# Pastikan konfigurasi Penny menggunakan header dari client chain.
sed -i \
's|RequestHeader set X-Real-IP.*|RequestHeader set X-Real-IP "%{HTTP:X-Forwarded-For}i"|' \
/etc/apache2/sites-enabled/penny.conf

echo
echo "===== X-REAL-IP CONFIG ====="
grep -R "RequestHeader set X-Real-IP" \
    /etc/apache2/conf-available/soal14-real-ip.conf \
    /etc/apache2/sites-enabled/penny.conf

echo
echo "===== APACHE CONFIG TEST ====="
apachectl configtest

echo
echo "===== RELOAD APACHE ====="
apachectl -k graceful

echo
echo "========================================"
echo " FIX SELESAI"
echo "========================================"