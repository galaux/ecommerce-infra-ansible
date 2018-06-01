#!/bin/sh

/sbin/sendmail -t <<EOF
To: $1
From: systemd <root@$HOSTNAME>
Subject: $HOSTNAME: $2 fail
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8

$(systemctl status --full --lines 100 "$2")
EOF
