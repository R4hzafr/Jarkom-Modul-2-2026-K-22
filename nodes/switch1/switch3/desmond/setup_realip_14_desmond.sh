#!/bin/bash

echo "SETUP REAL IP DESMOND"

cp /etc/apache2/conf-enabled/real-client-log.conf \
/etc/apache2/conf-enabled/real-client-log.conf.bak

cat > /etc/apache2/conf-enabled/real-client-log.conf <<EOF
LogFormat "REMOTE=%a XREAL=%{X-Real-IP}i XFORWARD=%{X-Forwarded-For}i HOST=%{Host}i %r" realclient
EOF

apachectl -t

if [ $? -eq 0 ]; then
    apachectl -k graceful
    echo "DESMOND DONE"
fi