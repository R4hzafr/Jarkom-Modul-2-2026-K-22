#!/bin/bash

set -e

echo "======================================"
echo " REVERSE PROXY - PENNY - SOAL 11"
echo "======================================"

echo
echo "[1/6] Installing Apache..."
apt-get update
apt-get install -y apache2

echo
echo "[2/6] Enabling Apache proxy modules..."

a2enmod proxy
a2enmod proxy_http
a2enmod headers
a2enmod proxy_balancer
a2enmod lbmethod_byrequests

echo
echo "[3/6] Configuring reverse proxy..."

rm -f /etc/apache2/sites-enabled/000-default.conf

cat > /etc/apache2/sites-available/penny-proxy.conf <<'CONF'
<VirtualHost *:80>

    ServerName penny.k22.com

    ProxyRequests Off
    ProxyPreserveHost On

    <Proxy "balancer://vault_cluster">
        BalancerMember http://192.222.1.4
        BalancerMember http://192.222.1.5

        ProxySet lbmethod=byrequests
    </Proxy>

    ProxyPass        "/" "balancer://vault_cluster/"
    ProxyPassReverse "/" "balancer://vault_cluster/"

    RequestHeader set X-Real-IP %{REMOTE_ADDR}s

    ErrorLog ${APACHE_LOG_DIR}/penny_proxy_error.log
    CustomLog ${APACHE_LOG_DIR}/penny_proxy_access.log combined

</VirtualHost>
CONF

a2ensite penny-proxy.conf

echo
echo "[4/6] Testing Apache configuration..."

apachectl configtest

echo
echo "[5/6] Starting / reloading Apache..."

if pgrep -x apache2 >/dev/null 2>&1; then
    apachectl -k graceful
else
    apachectl -k start
fi

echo
echo "[6/6] Checking Apache..."

pgrep -a apache2 || true

echo
echo "======================================"
echo " PENNY REVERSE PROXY READY"
echo "======================================"
echo
echo "Gateway : penny.k22.com"
echo
echo "Backend:"
echo "  192.222.1.4 -> Obladi"
echo "  192.222.1.5 -> Desmond"
echo
echo "Headers:"
echo "  Host       -> preserved"
echo "  X-Real-IP -> forwarded"
echo
echo "Test:"
echo "  curl http://penny.k22.com/arsip/"
echo