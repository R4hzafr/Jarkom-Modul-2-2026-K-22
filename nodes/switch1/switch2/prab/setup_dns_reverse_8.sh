#!/bin/bash

set -e

ZONE="222.192.in-addr.arpa"
ZONE_FILE="/etc/bind/jarkom/db.192.222"
NAMED_LOCAL="/etc/bind/named.conf.local"
TEDD_IP="192.222.1.3"

echo "======================================"
echo " DNS REVERSE SETUP - SOAL 8"
echo " MASTER: PRAB"
echo "======================================"

echo
echo "[1/5] Checking zone file..."

if [ ! -f "$ZONE_FILE" ]; then
    echo "Creating $ZONE_FILE..."

    cat > "$ZONE_FILE" <<'EOF'
$TTL    604800

@       IN      SOA     prab.k22.com. root.k22.com. (
                        2026093008
                        604800
                        86400
                        2419200
                        604800
)

@       IN      NS      prab.k22.com.
@       IN      NS      tedd.k22.com.

2.2     IN      PTR     abbey.k22.com.
2.3     IN      PTR     penny.k22.com.

4.1     IN      PTR     obladi.k22.com.
5.1     IN      PTR     desmond.k22.com.

6.1     IN      PTR     oblada.k22.com.
7.1     IN      PTR     molly.k22.com.
EOF

else
    echo "Zone file already exists."
fi


echo
echo "[2/5] Checking zone configuration..."

if ! grep -q 'zone "222.192.in-addr.arpa"' "$NAMED_LOCAL"; then

    cat >> "$NAMED_LOCAL" <<EOF

zone "222.192.in-addr.arpa" {
    type master;
    file "$ZONE_FILE";

    notify yes;

    also-notify {
        $TEDD_IP;
    };

    allow-transfer {
        $TEDD_IP;
    };
};
EOF

    echo "Reverse zone configuration added."
else
    echo "Reverse zone configuration already exists."
fi


echo
echo "[3/5] Checking zone file..."

named-checkzone "$ZONE" "$ZONE_FILE"


echo
echo "[4/5] Checking BIND configuration..."

named-checkconf


echo
echo "[5/5] Reloading BIND..."

kill -HUP "$(pidof named)"

sleep 2


echo
echo "======================================"
echo " REVERSE DNS - SOAL 8 READY"
echo "======================================"
echo
echo "Zone   : $ZONE"
echo "Master : prab.k22.com."
echo "Slave  : tedd.k22.com."
echo
echo "PTR Records:"
echo "192.222.2.2 -> abbey.k22.com."
echo "192.222.3.2 -> penny.k22.com."
echo "192.222.1.4 -> obladi.k22.com."
echo "192.222.1.5 -> desmond.k22.com."
echo "192.222.1.6 -> oblada.k22.com."
echo "192.222.1.7 -> molly.k22.com."
echo