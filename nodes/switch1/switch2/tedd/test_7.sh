for host in vault core www static; do
    echo "=== $host.k22.com ==="
    dig @192.222.1.2 "$host.k22.com" +short
    echo
done