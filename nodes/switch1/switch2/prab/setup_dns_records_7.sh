#!/bin/bash

set -e

ZONE="k22.com"
ZONE_FILE="/etc/bind/jarkom/$ZONE"
NAMED_LOCAL="/etc/bind/named.conf.local"

echo "======================================"
echo " DNS SETUP - SOAL 7"
echo "======================================"

echo
echo "[1/5] Checking zone file..."

if [ ! -f "$ZONE_FILE" ]; then
    echo "ERROR: Zone file tidak ditemukan:"
    echo "$ZONE_FILE"
    exit 1
fi


echo
echo "[2/5] Ensuring correct zone configuration..."

cat > "$NAMED_LOCAL" <<'CONF'
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
CONF


echo
echo "[3/5] Updating DNS records..."

# Hapus blok Soal 7 jika sebelumnya sudah pernah dibuat
sed -i '/; === DNS Records - Soal 7 ===/,$d' "$ZONE_FILE"

# Ambil SOA serial
CURRENT_SERIAL=$(awk '/^[[:space:]]*[0-9]+[[:space:]]*$/ {print $1; exit}' "$ZONE_FILE")

if [ -z "$CURRENT_SERIAL" ]; then
    echo "ERROR: SOA serial tidak ditemukan."
    exit 1
fi

NEW_SERIAL=$((CURRENT_SERIAL + 1))

# Update serial
sed -i "0,/$CURRENT_SERIAL/s//$NEW_SERIAL/" "$ZONE_FILE"

echo "Serial: $CURRENT_SERIAL -> $NEW_SERIAL"


cat >> "$ZONE_FILE" <<'RECORDS'

; === DNS Records - Soal 7 ===

; Static Web
vault  IN A 192.222.1.4
vault  IN A 192.222.1.5

; Dynamic Web
core   IN A 192.222.1.6
core   IN A 192.222.1.7

; CNAME
www    IN CNAME penny.k22.com.
static IN CNAME abbey.k22.com.
RECORDS


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
echo " DNS RECORDS - SOAL 7 READY"
echo "======================================"
echo