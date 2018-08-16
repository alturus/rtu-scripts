#!/bin/ash
#
# get_status_report.sh
#
# Сollect information about the current state of the router and generates
# a report file for subsequent transfer to the post-processing server
#

REPORT_FILE="/tmp/status_report"

printf "# date\n" > $REPORT_FILE
date >> $REPORT_FILE

printf "\n# uptime\n" >> $REPORT_FILE
uptime >> $REPORT_FILE

printf "\n# dirs_list.sh /IN/\n" >> $REPORT_FILE
/root/scripts/dirs_list.sh /IN/ >> $REPORT_FILE

printf "\n# dirs_list.sh /OUT/\n" >> $REPORT_FILE
/root/scripts/dirs_list.sh /OUT/ >> $REPORT_FILE

printf "\n# blkid\n" >> $REPORT_FILE
blkid >> $REPORT_FILE

printf "\n# df -h\n" >> $REPORT_FILE
df -h >> $REPORT_FILE

printf "\n# free\n" >> $REPORT_FILE
free >> $REPORT_FILE

printf "\n# arp\n" >> $REPORT_FILE
cat /proc/net/arp >> $REPORT_FILE

printf "\n# cat /tmp/dhcp.leases\n" >> $REPORT_FILE
cat /tmp/dhcp.leases >> $REPORT_FILE

printf "\n# ifconfig\n" >> $REPORT_FILE
ifconfig >> $REPORT_FILE
