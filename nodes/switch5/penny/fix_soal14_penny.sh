#!/bin/bash
set -e

echo "=== FIX SOAL 14 - PENNY ==="

cat > /etc/apache2/conf-available/soal14-real-ip.conf <<'CONF'
SetEnvIf Remote_Addr "^(.+)$" REAL_CLIENT_IP=$1
RequestHeader set X-Real-IP "%{REAL_CLIENT_IP}e"
CONF

a2enmod setenvif headers
a2enconf soal14-real-ip

echo
echo "=== X-REAL-IP CONFIG ==="
cat /etc/apache2/conf-available/soal14-real-ip.conf

echo
echo "=== CONFIG TEST ==="
apachectl configtest

echo
echo "=== RELOAD ==="
apachectl -k graceful

echo
echo "=== SELESAI ==="