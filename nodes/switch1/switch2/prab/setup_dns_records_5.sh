#!/bin/bash

set -e

ZONE="k22.com"
ZONE_FILE="/etc/bind/jarkom/$ZONE"
NAMED_LOCAL="/etc/bind/named.conf.local"

echo "======================================"
echo " DNS SETUP - SOAL 5"
echo "======================================"

echo
echo "[1/5] Checking zone file..."

if [ ! -f "$ZONE_FILE" ]; then
    echo "ERROR: $ZONE_FILE tidak ditemukan."
    exit 1
fi


echo
echo "[2/5] Updating named.conf.local..."

cat > "$NAMED_LOCAL" <<'EOF'
zone "k22.com" {
    type master;
    file "/etc/bind/jarkom/k22.com";

    notify yes;

    also-notify {
        192.222.1.3;
    };

    allow-transfer {
        192.222.1.3;
    };
};
EOF


echo
echo "[3/5] Adding DNS A records..."

# Hapus blok Soal 5 jika sebelumnya sudah pernah ditambahkan
sed -i '/; === Node A Records - Soal 5 ===/,$d' "$ZONE_FILE"

# Ambil serial sekarang
CURRENT_SERIAL=$(awk '/^[[:space:]]*[0-9]+[[:space:]]*$/ {print $1; exit}' "$ZONE_FILE")

if [ -z "$CURRENT_SERIAL" ]; then
    echo "ERROR: SOA serial tidak ditemukan."
    exit 1
fi

NEW_SERIAL=$((CURRENT_SERIAL + 1))

# Update serial
sed -i "0,/$CURRENT_SERIAL/s//$NEW_SERIAL/" "$ZONE_FILE"

echo "Serial: $CURRENT_SERIAL -> $NEW_SERIAL"

# Tambahkan records
cat >> "$ZONE_FILE" <<'EOF'

; === Node A Records - Soal 5 ===

rootkit IN A 192.168.122.6

alpha   IN A 192.222.4.2
beta    IN A 192.222.4.3
gamma   IN A 192.222.4.4

delta   IN A 192.222.5.2
epsilon IN A 192.222.5.3

abbey   IN A 192.222.2.2
penny   IN A 192.222.3.2

obladi  IN A 192.222.1.4
desmond IN A 192.222.1.5

oblada  IN A 192.222.1.6
molly   IN A 192.222.1.7
EOF


echo
echo "[4/5] Checking BIND configuration..."

named-checkconf
named-checkzone "$ZONE" "$ZONE_FILE"


echo
echo "[5/5] Reloading BIND..."

NAMED_PID=$(pidof named || true)

if [ -n "$NAMED_PID" ]; then
    kill -HUP "$NAMED_PID"
    echo "BIND reload signal sent to PID: $NAMED_PID"
else
    echo "ERROR: named tidak sedang berjalan."
    exit 1
fi


echo
echo "======================================"
echo " DNS RECORDS - SOAL 5 READY"
echo "======================================"