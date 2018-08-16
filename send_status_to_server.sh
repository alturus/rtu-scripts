#!/bin/ash
#
# send_status_to_server.sh
#

# Post-processing FTP-server connection config file
source /root/scripts/ftp_config.sh

DIR_LOG="/mnt/usb/ftproot/LOG"

# Device dir for status reports: R_{MAC of eth0}
DIR_DEV="/R_`ifconfig eth0 | grep "eth0" | awk '{print $5}' | tr -d ':'`"
REPORT_SRC="/tmp/status_report"
REPORT_DST="status_report_$(date +%Y%m%d%H%M%S)"

FILES_EXIST=0 # If no files don't execute lftp-client

MASK_TMP="*_tmp"

SCRIPT_NAME=$(basename "$0")
LOG_NAME="${SCRIPT_NAME%.sh}_$(date +%Y%m%d).log"

# Check if script already running...
for pid in $(pidof $SCRIPT_NAME); do
  if [ $pid != $$ ]; then
    echo "Script is already running with PID $pid"
    exit 1
  fi
done

# Commands to configure FTP session in lftp client
COMMANDS="set xfer:log yes; set xfer:log-file $DIR_LOG/$LOG_NAME; "
COMMANDS="$COMMANDS set ftp:ssl-allow no; set net:timeout 20; set net:reconnect-interval-base 5; set net:max-retries 2; set ftp:prefer-epsv no; set xfer:use-temp-file yes; set xfer:temp-file-name $MASK_TMP; "

# If status report file exists add it for transfer
if [ -e $REPORT_SRC ]; then
  # Check if DIR_DEV exists on post-processing FTP-server
  # if not - create dir
  COMMANDS_MKDIR="cd $DIR_DEV || mkdir -p $DIR_DEV; cd $DIR_DEV; "

  COMMANDS_REPORT="put -E $REPORT_SRC -o $REPORT_DST; cd /; "
  COMMANDS="$COMMANDS $COMMANDS_MKDIR $COMMANDS_REPORT"
  FILES_EXIST=1
fi

COMMANDS="$COMMANDS bye;"

if [ $FILES_EXIST -eq 1 ]; then
  echo "lftp"
  lftp -e "$COMMANDS" -u $USER,$PASS $SERVER_IP
else
  echo "No files to transfer"
fi
