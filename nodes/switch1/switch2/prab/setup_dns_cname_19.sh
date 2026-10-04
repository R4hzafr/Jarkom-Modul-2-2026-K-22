#!/bin/bash

set -e

echo "======================================"
echo " DNS CNAME - SOAL 19"
echo " MASTER : PRAB"
echo "======================================"

ZONE="/etc/bind/jarkom/k22.com"


echo "[1] Backup zone file"

cp $ZONE ${ZONE}.bak-soal19


echo
echo "[2] Tambah CNAME outbound"


if ! grep -q "^outbound" $ZONE
then
cat >> $ZONE <<EOF

; ================================
; SOAL 19 CNAME RECORD
; ================================

outbound    IN    CNAME    http.badssl.com.

EOF
else
    echo "outbound sudah ada"
fi


echo
echo "[3] Update serial SOA"


NEW_SERIAL=$(date +%Y%m%d%H)

sed -i -E "0,/([0-9]{10})/s//${NEW_SERIAL}/" $ZONE


echo
echo "[4] Check zone"

named-checkzone k22.com $ZONE


echo
echo "[5] Reload named"

kill -HUP $(pidof named)


echo
echo "======================================"
echo " SOAL 19 READY"
echo "======================================"

echo
echo "Testing:"
echo "dig outbound.k22.com"
echo "curl http://outbound.k22.com"