#!/bin/bash

set -e

echo "======================================"
echo " BASIC AUTH - SOAL 12"
echo "======================================"
echo

ADMIN_DIR="/var/www/penny-admin"
AUTH_FILE="/etc/apache2/.htpasswd-penny"

USERNAME="prabs"
PASSWORD="pakar_pinter_jadi_gob***"

echo "[1/6] Installing apache2-utils..."
apt-get update
apt-get install -y apache2-utils

echo "[2/6] Creating /admin directory..."
mkdir -p "$ADMIN_DIR"

cat > "$ADMIN_DIR/index.html" <<'HTML'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Penny Admin</title>
</head>
<body>
    <h1>ADMIN AREA</h1>
    <p>Dokumen rahasia sindikat.</p>
    <p>Hostname: penny</p>
    <p>Basic Authentication berhasil.</p>
</body>
</html>
HTML

echo "[3/6] Creating Basic Authentication credentials..."

htpasswd -bc "$AUTH_FILE" "$USERNAME" "$PASSWORD"

chmod 640 "$AUTH_FILE"
chown root:www-data "$AUTH_FILE"

echo "[4/6] Configuring /admin..."

cat > /etc/apache2/conf-available/penny-admin-auth.conf <<EOF2
# Jangan proxy-kan /admin ke backend
ProxyPass /admin !

Alias /admin "$ADMIN_DIR"

<Directory "$ADMIN_DIR">
    Options -Indexes
    AllowOverride None
    Require valid-user

    AuthType Basic
    AuthName "Penny Admin Area"
    AuthUserFile "$AUTH_FILE"
</Directory>
EOF2

echo "[5/6] Enabling configuration..."

a2enmod auth_basic authn_file
a2enconf penny-admin-auth

echo "[6/6] Checking and restarting Apache..."

apachectl configtest

if command -v systemctl >/dev/null 2>&1; then
    systemctl restart apache2
else
    apachectl -k restart
fi

echo
echo "======================================"
echo " BASIC AUTH - SOAL 12 READY"
echo "======================================"
echo
echo "Hostname : $(hostname)"
echo "Path     : /admin"
echo
echo "Username : $USERNAME"
echo "Password : $PASSWORD"
echo
echo "Test tanpa credential:"
echo "  curl -i http://penny.k22.com/admin/"
echo
echo "Test dengan credential:"
echo "  curl -i -u '$USERNAME:$PASSWORD' http://penny.k22.com/admin/"
echo
echo "Apache:"
apachectl -S 2>&1 | head -30