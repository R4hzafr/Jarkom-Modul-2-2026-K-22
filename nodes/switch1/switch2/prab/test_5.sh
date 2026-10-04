#!/bin/bash

set -e

for host in rootkit alpha beta gamma delta epsilon abbey penny obladi desmond oblada molly; do
    echo -n "$host.k22.com -> "
    dig @127.0.0.1 "$host.k22.com" +short
done