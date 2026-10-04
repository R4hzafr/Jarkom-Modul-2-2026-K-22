#!/bin/bash
set -e

echo "======================================"
echo " SOAL 15 - PENNY /eternal FIX"
echo "======================================"

DOMAIN="penny.k22.com"
WEBROOT="/var/www/eternal"
SOCKET="/run/php/php8.4-fpm.sock"

echo "[1] Membuat directory eternal..."

mkdir -p $WEBROOT


echo "[2] Membuat file PHP test..."

cat > $WEBROOT/index.php <<EOF
<!DOCTYPE html>
<html>
<head>
<title>Eternal PHP</title>
</head>
<body>

<h1>ETERNAL PATH</h1>

<p>Server : Penny</p>
<p>Path   : /eternal</p>
<p>PHP Rendering OK</p>

</body>
</html>
EOF


cat > $WEBROOT/test.php <<EOF
<?php
phpinfo();
?>
EOF


echo "[3] Permission..."

chmod -R 755 $WEBROOT


echo "[4] Membuat konfigurasi Apache..."

cat > /etc/apache2/sites-available/penny.conf <<EOF
<VirtualHost *:80>

    ServerName penny.k22.com
    ServerAlias 192.222.3.2


    # =========================
    # SOAL 15 - ETERNAL PHP
    # =========================

    Alias /eternal $WEBROOT

    <Directory $WEBROOT>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>


    <FilesMatch \.php$>
        SetHandler "proxy:unix:$SOCKET|fcgi://localhost/"
    </FilesMatch>


    # =========================
    # SOAL 13 - REDIRECT
    # =========================

    RewriteEngine On

    RewriteCond %{REQUEST_URI} !^/eternal
    RewriteRule ^/(.*)$ http://www.k22.com/\$1 [R=301,L]


</VirtualHost>


# =========================
# SOAL 11 - REVERSE PROXY
# =========================

<VirtualHost *:80>

    ServerName www.k22.com

    ProxyRequests Off
    ProxyPreserveHost On


    <Proxy "balancer://vault_cluster">

        BalancerMember http://192.222.1.4
        BalancerMember http://192.222.1.5

        ProxySet lbmethod=byrequests

    </Proxy>


    ProxyPass "/" "balancer://vault_cluster/"
    ProxyPassReverse "/" "balancer://vault_cluster/"


    RequestHeader set X-Real-IP %{REMOTE_ADDR}s

</VirtualHost>

EOF


echo "[5] Enable module..."

a2enmod rewrite proxy proxy_fcgi proxy_http proxy_balancer lbmethod_byrequests headers


echo "[6] Disable config lama..."

a2dissite penny-proxy.conf 2>/dev/null || true


echo "[7] Enable penny..."

a2ensite penny.conf


echo "[8] Test Apache..."

apachectl configtest


echo "[9] Reload Apache..."

apachectl -k graceful


echo
echo "======================================"
echo " SOAL 15 PENNY READY"
echo "======================================"

echo
echo "Test:"
echo "curl http://penny.k22.com/eternal/"
echo "curl http://penny.k22.com/eternal/test.php"