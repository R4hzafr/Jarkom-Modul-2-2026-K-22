#!/bin/bash

set -e

echo "======================================"
echo " DNS TTL UPDATE - SOAL 18"
echo " MASTER : PRAB"
echo "======================================"

ZONE="/etc/bind/jarkom/k22.com"

OLD_IP="192.222.2.2"
NEW_IP="192.222.9.99"


echo "[1] Backup zone"

cp $ZONE ${ZONE}.bak-soal18


echo
echo "[2] Update abbey A record"

sed -i "/^abbey[[:space:]]\+IN[[:space:]]\+A/d" $ZONE
sed -i "/^abbey[[:space:]]\+[0-9]\+[[:space:]]\+IN[[:space:]]\+A/d" $ZONE

echo "abbey    15    IN    A    $NEW_IP" >> $ZONE


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
echo " SOAL 18 READY"
echo "======================================"

echo
echo "ABBey sekarang:"
echo "IP  : $NEW_IP"
echo "TTL : 15 detik"

echo
echo "Test:"

echo "dig abbey.k22.com"