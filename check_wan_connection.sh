#!/bin/ash
#
# check_wan_connection.sh
#
# Check WAN connection and reconnect if disconnected
# After 8 unsuccessful attempts, reboot the router.
#

HOST="8.8.8.8"
TMP_FILE="/tmp/check_wan_connection.tmp"

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

FAILSREST=`expr $FAILS % 3`

if [ $FAILSREST -eq "0" ]; then
	echo $FAILS
	echo "down wan"
	ifdown wan
	sleep 10
	ifup wan
	echo "wan is upped"
fi

echo $FAILS > $TMP_FILE

if [ $FAILS -gt 7 ]; then
	reboot
fi
