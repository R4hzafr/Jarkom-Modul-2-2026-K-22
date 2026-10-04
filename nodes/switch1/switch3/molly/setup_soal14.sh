#!/bin/bash
set -e

echo "=== SOAL 14 - MOLLY ==="

# Format log menggunakan X-Real-IP
cat > /etc/nginx/conf.d/real-client-log.conf <<'CONF'
log_format realclient '$http_x_real_ip - $remote_user [$time_local] '
                      '"$request" $status $body_bytes_sent '
                      '"$http_referer" "$http_user_agent"';
CONF

# Ubah access_log yang menggunakan format default menjadi realclient
find /etc/nginx/sites-available -type f -exec \
    sed -i 's/access_log \(.*\);/access_log \1 realclient;/' {} \;

# Pastikan access log utama memakai realclient
cat > /etc/nginx/conf.d/soal14-access-log.conf <<'CONF'
access_log /var/log/nginx/access.log realclient;
CONF

nginx -t
nginx -s reload

echo
echo "=== MOLLY SELESAI ==="