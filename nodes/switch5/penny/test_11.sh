for i in {1..10}; do
    echo "===== REQUEST $i ====="
    curl -s http://penny.k22.com/arsip/index.txt
    echo
done