#!/bin/bash

set -e

echo "======================================"
echo " REVERSE PROXY - ABBEY - SOAL 11"
echo "======================================"

echo
echo "[1/6] Installing Nginx..."

apt-get update
apt-get install -y nginx

echo
echo "[2/6] Configuring Nginx reverse proxy..."

rm -f /etc/nginx/sites-enabled/default

cat > /etc/nginx/sites-available/abbey-proxy <<'CONF'
upstream core_cluster {
    server 192.222.1.6;
    server 192.222.1.7;
}

server {
    listen 80;

    server_name abbey.k22.com;

    location / {
        proxy_pass http://core_cluster;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;

        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    access_log /var/log/nginx/abbey_proxy_access.log;
    error_log  /var/log/nginx/abbey_proxy_error.log;
}
CONF

ln -sf /etc/nginx/sites-available/abbey-proxy \
       /etc/nginx/sites-enabled/abbey-proxy

echo
echo "[3/6] Testing Nginx configuration..."

nginx -t

echo
echo "[4/6] Starting / reloading Nginx..."

if pgrep -x nginx >/dev/null 2>&1; then
    nginx -s reload
else
    nginx
fi

echo
echo "[5/6] Checking Nginx..."

pgrep -a nginx || true

echo
echo "[6/6] Done."

echo
echo "======================================"
echo " ABBEY REVERSE PROXY READY"
echo "======================================"
echo
echo "Gateway : abbey.k22.com"
echo
echo "Backend:"
echo "  192.222.1.6 -> Oblada"
echo "  192.222.1.7 -> Molly"
echo
echo "Headers:"
echo "  Host       -> forwarded"
echo "  X-Real-IP -> forwarded"
echo
echo "Test:"
echo "  curl http://abbey.k22.com/"
echo "  curl http://abbey.k22.com/profil"
echo