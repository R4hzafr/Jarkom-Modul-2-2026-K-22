for i in {1..10}; do
    echo "===== REQUEST $i ====="
    curl -s http://abbey.k22.com/
    echo
done