#!/bin/bash

echo "===== PENNY ====="
curl -I http://penny.k22.com/
curl -I http://192.222.3.2/

echo
echo "===== WWW ====="
curl -I http://www.k22.com/

echo
echo "===== ABBEY ====="
curl -I http://abbey.k22.com/
curl -I http://192.222.2.2/

echo
echo "===== STATIC ====="
curl -I http://static.k22.com/