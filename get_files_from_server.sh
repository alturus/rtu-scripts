#!/bin/ash
#
# get_files_from_server.sh
#
# Receive the files from the post-processing server for the measuring equipment
#

# config of FTP connection to the post-processing server
source /root/scripts/ftp_config.sh

DIR_OUT="/mnt/usb/ftproot/OUT"
DIR_LOG="/mnt/usb/ftproot/LOG"

MASK="*.*"
MASK_TMP="*_tmp"

WORK_DIRS="/tmp/work_dirs" # the list of directories we will work with

SCRIPT_NAME=$(basename "$0")
LOG_NAME="${SCRIPT_NAME%.sh}.log"

if [ ! -f $WORK_DIRS ]; then
	echo "File not found!"
	exit 0
fi

MIRROR_OUT_CMDS=""

while read DIR; do
	TMP_OUT=$MIRROR_OUT_CMDS
	MIRROR_OUT_CMDS="$TMP_OUT mirror -p -c -X '$MASK_TMP' -I '*.*' --Remove-source-files --verbose ./OUT/$DIR $DIR_OUT/$DIR; "
done < $WORK_DIRS

COMMANDS="set xfer:log yes; set xfer:log-file $DIR_LOG/$LOG_NAME; "
COMMANDS="$COMMANDS set ftp:ssl-allow no; set ftp:prefer-epsv no; set xfer:use-temp-file yes; set xfer:temp-file-name $MASK_TMP; "
COMMANDS_OUT="$COMMANDS $MIRROR_OUT_CMDS bye;"

lftp -e "$COMMANDS_OUT" -u $USER,$PASS $SERVER_IP
