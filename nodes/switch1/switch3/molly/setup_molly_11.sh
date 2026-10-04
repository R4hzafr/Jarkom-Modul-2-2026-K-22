#!/bin/bash

echo "[1/3] Installing Nginx..."
apt update
apt install nginx -y

echo "[2/3] Starting Nginx..."
service nginx restart

echo "[3/3] Testing..."
nginx -t
curl -I http://127.0.0.1

echo
echo "======================================"
echo "Molly backend ready"
echo "IP: 192.222.1.7"
echo "Port: 80"
echo "======================================"
