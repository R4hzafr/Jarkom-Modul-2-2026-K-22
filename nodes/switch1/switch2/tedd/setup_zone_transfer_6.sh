#!/bin/bash

set -e

ZONE="k22.com"
MASTER="192.222.1.2"

echo "[1/3] Checking BIND configuration..."
named-checkconf

echo "[2/3] Checking SOA serial from Master and Slave..."

MASTER_SERIAL=$(dig @$MASTER "$ZONE" SOA +short | awk '{print $3}')
SLAVE_SERIAL=$(dig @127.0.0.1 "$ZONE" SOA +short | awk '{print $3}')

echo
echo "Prab  (Master): $MASTER_SERIAL"
echo "Tedd (Slave) : $SLAVE_SERIAL"
echo

if [ -z "$MASTER_SERIAL" ] || [ -z "$SLAVE_SERIAL" ]; then
    echo "ERROR: Tidak dapat membaca SOA serial."
    exit 1
fi

if [ "$MASTER_SERIAL" = "$SLAVE_SERIAL" ]; then
    echo "======================================"
    echo " ZONE TRANSFER SUCCESS"
    echo " SOA SERIAL MATCH"
    echo "======================================"
else
    echo "SOA serial berbeda."
    echo "Meminta zone refresh dari Master..."

    kill -HUP $(pidof named)
    sleep 3

    MASTER_SERIAL=$(dig @$MASTER "$ZONE" SOA +short | awk '{print $3}')
    SLAVE_SERIAL=$(dig @127.0.0.1 "$ZONE" SOA +short | awk '{print $3}')

    echo
    echo "Prab  (Master): $MASTER_SERIAL"
    echo "Tedd (Slave) : $SLAVE_SERIAL"
    echo

    if [ "$MASTER_SERIAL" = "$SLAVE_SERIAL" ]; then
        echo "======================================"
        echo " ZONE TRANSFER SUCCESS"
        echo " SOA SERIAL MATCH"
        echo "======================================"
    else
        echo "ERROR: Zone transfer belum berhasil."
        exit 1
    fi
fi