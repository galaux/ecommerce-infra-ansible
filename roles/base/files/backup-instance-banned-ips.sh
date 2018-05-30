#!/bin/sh

# DEST_DIR=$1
DEST_DIR_NO_DATE=$2

/sbin/iptables-save > ${DEST_DIR_NO_DATE}/iptables-save.log
