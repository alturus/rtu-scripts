#/bin/ash
#
# get_status_report_boot.sh
#

sleep 2m
/root/scripts/get_status_report.sh
echo "LOG:" >> /tmp/status_report
logread >> /tmp/status_report
