#!/bin/bash

set -e

ZONE="k22.com"
ZONE_DIR="/etc/bind/jarkom"
ZONE_FILE="$ZONE_DIR/$ZONE"

echo "[1/6] Installing BIND9..."
apt update
apt install bind9 bind9-utils bind9-dnsutils -y

echo "[2/6] Preparing zone directory..."
mkdir -p "$ZONE_DIR"

echo "[3/6] Configuring named.conf.options..."
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

echo "[4/6] Configuring authoritative zone..."
cat > /etc/bind/named.conf.local <<'EOF'
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

echo "[5/6] Creating zone file..."
cat > "$ZONE_FILE" <<'EOF'
$TTL    604800

@       IN      SOA     prab.k22.com. root.k22.com. (
                        2026093001
                        604800
                        86400
                        2419200
                        604800
)

@       IN      NS      prab.k22.com.
@       IN      NS      tedd.k22.com.

prab    IN      A       192.222.1.2
tedd    IN      A       192.222.1.3

@       IN      A       192.222.3.2
EOF

echo "[6/6] Checking configuration..."
named-checkconf
named-checkzone "$ZONE" "$ZONE_FILE"

echo
echo "Restarting BIND..."
if [ -x /etc/init.d/bind9 ]; then
    service bind9 restart
else
    pkill named 2>/dev/null || true
    named -c /etc/bind/named.conf
fi

echo
echo "=== DNS MASTER READY ==="
echo
dig @127.0.0.1 "$ZONE"
echo
dig @127.0.0.1 "$ZONE" NS