#!/bin/bash

echo "SETUP REAL IP OBLADI"

cp /etc/apache2/conf-enabled/debug-real-ip.conf \
/etc/apache2/conf-enabled/debug-real-ip.conf.bak

cat > /etc/apache2/conf-enabled/debug-real-ip.conf <<EOF
LogFormat "REMOTE=%a CLIENTIP=%{X-Forwarded-For}i HOST=%{Host}i %r" debugip
EOF

apachectl -t

if [ $? -eq 0 ]; then
    apachectl -k graceful
    echo "OBLADI DONE"
fi