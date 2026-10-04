#!/bin/bash

set -e

ZONE="222.192.in-addr.arpa"
MASTER_IP="192.222.1.2"
SLAVE_DIR="/var/cache/bind"
SLAVE_FILE="$SLAVE_DIR/db.192.222"
NAMED_LOCAL="/etc/bind/named.conf.local"

echo "======================================"
echo " DNS REVERSE SLAVE - SOAL 8"
echo " SLAVE: TEDD"
echo "======================================"

echo
echo "[1/4] Checking slave zone configuration..."

if ! grep -q 'zone "222.192.in-addr.arpa"' "$NAMED_LOCAL"; then

    cat >> "$NAMED_LOCAL" <<EOF

zone "222.192.in-addr.arpa" {
    type slave;
    masters {
        $MASTER_IP;
    };
    file "$SLAVE_FILE";
};
EOF

    echo "Slave reverse zone configuration added."

else
    echo "Slave reverse zone configuration already exists."
fi


echo
echo "[2/4] Checking BIND configuration..."

named-checkconf


echo
echo "[3/4] Reloading BIND..."

kill -HUP "$(pidof named)"

sleep 3


echo
echo "[4/4] Checking zone transfer..."

SERIAL=$(dig @127.0.0.1 "$ZONE" SOA +short | awk '{print $3}')

if [ -z "$SERIAL" ]; then
    echo "ERROR: Reverse zone belum diterima dari master."
    exit 1
fi

echo "Slave serial: $SERIAL"


echo
echo "======================================"
echo " REVERSE DNS SLAVE - READY"
echo "======================================"
echo
echo "Zone   : $ZONE"
echo "Master : $MASTER_IP"
echo "Slave  : tedd"
echo "Serial : $SERIAL"
echo