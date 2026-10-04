#!/bin/bash
set -e

cat > /etc/nginx/sites-available/abbey.conf <<'EOF'
# =========================================================
# SOAL 13 - Redirect abbey -> static
# =========================================================
server {
    listen 80;
    listen [::]:80;

    server_name abbey.k22.com 192.222.2.2;

    return 302 http://static.k22.com$request_uri;

    access_log /var/log/nginx/abbey_redirect_access.log;
    error_log  /var/log/nginx/abbey_redirect_error.log;
}


# =========================================================
# SOAL 11 - Reverse Proxy static -> Core
# =========================================================
upstream core_cluster {
    server 192.222.1.6;
    server 192.222.1.7;
}

server {
    listen 80;
    listen [::]:80;

    server_name static.k22.com;

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
EOF

# Nonaktifkan config Abbey lama
rm -f /etc/nginx/sites-enabled/abbey-proxy

# Aktifkan config baru
ln -sf /etc/nginx/sites-available/abbey.conf \
       /etc/nginx/sites-enabled/abbey.conf

# Validasi
nginx -t

# Reload
nginx -s reload