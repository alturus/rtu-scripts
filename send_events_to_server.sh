#!/bin/ash
#
# send_events_to_server.sh
#
# Send event files (.ENT) from RTU to post-processing server
#

# Post-processing FTP-server connection config file
source /root/scripts/ftp_config.sh

DIR_IN="/mnt/usb/ftproot/IN"
DIR_LOG="/mnt/usb/ftproot/LOG"

FILES_EXIST=0 # If no files don't execute lftp-client

MASK="*.*"
MASK_TMP="*_tmp"

WORK_DIRS="/tmp/work_dirs" # the list of directories we will work with

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

# If there are files in DIR_IN except temp files (*_) and trp (*.tr*)
if [ "$(find $DIR_IN -type f ! -name '*_' ! -name '*.tr*' -name '*.*')" ]; then

  # Find dirs with files except temp and trp files
  DIRS_IN="$(find $DIR_IN -type f ! -name '*_' ! -name '*.tr*' -name '*.*' | sed -r 's|/[^/]+$||' | sort -u)"

  MIRROR_IN_CMDS=""
  for DIR_F in $DIRS_IN; do
  	DIR="${DIR_F##*/}"
  	echo $DIR

    # Create or/and append working dirs list
  	grep -q "$DIR" $WORK_DIRS || echo "$DIR" >> $WORK_DIRS

    # Creating list of commands to send files from dirs
  	TMP_IN=$MIRROR_IN_CMDS
  	MIRROR_IN_CMDS="$TMP_IN mirror -p -c -R -I '$MASK' -X '*_' -X '*_tmp' -X '*.tr*' --Remove-source-files --verbose $DIR_IN/$DIR ./IN/$DIR; "
  done
  COMMANDS="$COMMANDS $MIRROR_IN_CMDS bye;"
  FILES_EXIST=1
else
  echo "dirs are empty"
  COMMANDS="$COMMANDS bye;"
fi

if [ $FILES_EXIST -eq 1 ]; then
  echo "lftp"
  lftp -e "$COMMANDS" -u $USER,$PASS $SERVER_IP
else
  echo "No files to transfer"
fi
