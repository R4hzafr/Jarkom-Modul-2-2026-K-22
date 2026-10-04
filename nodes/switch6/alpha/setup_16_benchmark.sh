#!/bin/bash

set -e

echo "======================================"
echo " SOAL 16 - THE MESH BENCHMARK"
echo " ApacheBench Stress Test"
echo "======================================"

echo
echo "[1] Installing ApacheBench..."

apt update
apt install -y apache2-utils


echo
echo "[2] Testing www.k22.com"
echo "======================================"

ab -n 250 -c 10 http://www.k22.com/ \
| tee benchmark_www.txt


echo
echo "[3] Testing static.k22.com"
echo "======================================"

ab -n 250 -c 10 http://static.k22.com/ \
| tee benchmark_static.txt


echo
echo "======================================"
echo " RANGKUMAN HASIL"
echo "======================================"

echo
echo "=== www.k22.com ==="

grep -E \
"Complete requests|Failed requests|Requests per second|Time per request|Transfer rate" \
benchmark_www.txt


echo
echo "=== static.k22.com ==="

grep -E \
"Complete requests|Failed requests|Requests per second|Time per request|Transfer rate" \
benchmark_static.txt


echo
echo "======================================"
echo " FILE HASIL"
echo "======================================"

echo "benchmark_www.txt"
echo "benchmark_static.txt"