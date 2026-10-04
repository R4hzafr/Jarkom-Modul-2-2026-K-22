#!/bin/bash

set -e

ZONE="k22.com"

echo "[1/5] Installing BIND9..."
apt update
apt install bind9 bind9-utils bind9-dnsutils -y

echo "[2/5] Configuring named.conf.options..."
cat > /etc/bind/named.conf.options <<'EOF'
options {
    directory "/var/cache/bind";

    recursion yes;

    allow-query { any; };

    forwarders {
        192.168.122.1;
    };

    dnssec-validation no;

    listen-on { any; };
    listen-on-v6 { any; };
};
EOF

echo "[3/5] Configuring slave zone..."
cat > /etc/bind/named.conf.local <<'EOF'
zone "k22.com" {
    type slave;

    masters {
        192.222.1.2;
    };

    file "/var/cache/bind/k22.com";
};
EOF

echo "[4/5] Checking configuration..."
named-checkconf

echo "[5/5] Starting BIND..."
pkill named 2>/dev/null || true
named -c /etc/bind/named.conf

echo
echo "Waiting for zone transfer..."
sleep 2

echo
echo "=== TRANSFERRED ZONE ==="
ls -lah /var/cache/bind/

echo
echo "=== DNS TEST ==="
dig @127.0.0.1 "$ZONE"
echo
dig @127.0.0.1 "$ZONE" NS