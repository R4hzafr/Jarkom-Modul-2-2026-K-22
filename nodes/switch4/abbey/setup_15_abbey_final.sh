#!/bin/bash
set -e

echo "======================================"
echo " SOAL 15 - ABBEY /orion FINAL"
echo "======================================"

WEBROOT="/var/www/orion"
CONFIG="/etc/nginx/sites-enabled/abbey.conf"


echo "[1] Membuat directory orion"

mkdir -p $WEBROOT


echo "[2] Membuat file static"

cat > $WEBROOT/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
<title>Orion Static</title>
</head>

<body>

<h1>ORION STATIC PATH</h1>

<p>Server : Abbey</p>
<p>Path : /orion</p>
<p>Nginx Static OK</p>

</body>
</html>
EOF


chmod -R 755 $WEBROOT


echo "[3] Backup config lama"

cp $CONFIG ${CONFIG}.bak-soal15


echo "[4] Menambahkan location /orion"


python3 <<EOF

config="$CONFIG"

with open(config) as f:
    data=f.read()


block="""

    # === SOAL 15 /orion ===

    location /orion/ {

        alias /var/www/orion/;

        autoindex on;

        index index.html;

    }

"""


if "/orion/" not in data:

    data=data.replace(
        "    location / {",
        block + "\n    location / {"
    )


with open(config,"w") as f:
    f.write(data)

EOF


echo "[5] Test nginx"

nginx -t


echo "[6] Reload nginx"

nginx -s reload


echo
echo "======================================"
echo " ABBEY /orion READY"
echo "======================================"

echo
echo "Test:"
echo "curl http://abbey.k22.com/orion/"