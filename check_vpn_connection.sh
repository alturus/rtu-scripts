#!/bin/ash
#
# check_vpn_connection.sh
#
# Check VPN connection and reconnect if disconnected
#

IFACE="vpn"
HOST="172.22.122.1"
TMP_FILE="/tmp/check_vpn_connection.tmp"

if [ -r $TMP_FILE ]; then
	FAILS=`cat $TMP_FILE`
else
	FAILS=0
fi

ping -c 3 $HOST > /dev/null 2>&1
if [ $? -ne 0 ]; then
	FAILS=`expr $FAILS + 1`
else
	FAILS=0
fi

if [ $FAILS -gt 3 ]; then
	ifdown $IFACE
	sleep 10
	ifup $IFACE
	FAILS=0
fi

echo $FAILS > $TMP_FILE
