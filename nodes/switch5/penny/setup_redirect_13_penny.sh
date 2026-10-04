#!/bin/bash
set -e

cat > /etc/apache2/sites-available/penny.conf <<'EOF'
# =========================================================
# SOAL 13 - Redirect penny -> www
# =========================================================
<VirtualHost *:80>
    ServerName penny.k22.com
    ServerAlias 192.222.3.2

    Redirect 301 / http://www.k22.com/
</VirtualHost>


# =========================================================
# SOAL 11 - Reverse Proxy www -> Vault
# =========================================================
<VirtualHost *:80>
    ServerName www.k22.com

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
EOF

# Pastikan module yang dibutuhkan aktif
a2enmod proxy proxy_http proxy_balancer lbmethod_byrequests headers

# Nonaktifkan konfigurasi lama agar tidak bentrok
a2dissite penny-proxy.conf 2>/dev/null || true

# Aktifkan konfigurasi baru
a2ensite penny.conf

# Validasi
apachectl configtest

# Reload Apache
apachectl -k graceful