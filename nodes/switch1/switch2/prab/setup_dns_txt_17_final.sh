#!/bin/bash
set -e

echo "======================================"
echo " DNS TXT RECORD - SOAL 17 FINAL"
echo " MASTER : PRAB"
echo "======================================"

ZONE="/etc/bind/jarkom/k22.com"


echo "[1] Backup zone file"

cp $ZONE ${ZONE}.bak-soal17


echo "[2] Menambahkan TXT record"


for host in alpha beta gamma delta epsilon
do
    if ! grep -q "^$host[[:space:]].*TXT" $ZONE
    then
        echo "$host    IN TXT \"$host\"" >> $ZONE
    else
        echo "$host TXT sudah ada"
    fi
done


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
echo " DNS TXT SOAL 17 READY"
echo "======================================"

echo
echo "Testing:"
echo "dig TXT alpha.k22.com"
echo "dig TXT beta.k22.com"
echo "dig TXT gamma.k22.com"
echo "dig TXT delta.k22.com"
echo "dig TXT epsilon.k22.com"