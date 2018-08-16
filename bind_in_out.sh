#!/bin/ash
#
# bind_in_out.sh
#
# Bind directories IN and OUT on the external flash-drive
# to the root of the router's file system.
#

DIR_MNT=/mnt/usb
DIR_ROOT="$DIR_MNT/ftproot"
DIR_IN="$DIR_ROOT/IN"
DIR_OUT="$DIR_ROOT/OUT"
DIR_LOG="$DIR_ROOT/LOG"

# сheck if the flash-drive is mounted to /mnt/usb
if [ "`df -h | grep "$DIR_MNT" | awk '{print $6}'`/" = "$DIR_MNT/" ]; then
    # сheck and create the required directories on the flash-drive
    if [ ! -d $DIR_ROOT ]; then
        mkdir $DIR_ROOT && echo "$DIR_ROOT created"
        mkdir $DIR_IN && echo "$DIR_IN created"
        mkdir $DIR_OUT && echo "$DIR_OUT created"
        mkdir $DIR_LOG && echo "$DIR_LOG created"
    else                                         # DIR_ROOT exists but...
        if [ ! -d $DIR_IN ]; then                # if DIR_IN doesn't exist
            mkdir $DIR_IN && echo "DIR_IN created"
        fi

        if [ ! -d $DIR_OUT ]; then               # if DIR_OUT doesn't exist
            mkdir $DIR_OUT && echo "$DIR_OUT created"
        fi

        if [ ! -d $DIR_LOG ]; then               # if DIR_LOG doesn't exist
            mkdir $DIR_LOG && echo "$DIR_LOG created"
        fi
    fi

    if [ "$(ls -A /IN)" ]; then # dir is not empty
        if [ -f "/IN/not_mounted" ]; then # if file "not_mounted" exists (dir /IN not mounted)
            /bin/mount --bind "$DIR_IN" /IN && echo "$DIR_IN mounted"
        else
            echo "/IN is already mounted."
        fi
    else # dir is empty
        /bin/touch /IN/mounted_ 2> /dev/null  # trying to create file in /IN
        if [ $? -eq 0 ]; then                 # if file created...
            echo "/IN is already mounted."
        else
            /bin/umount /IN
            /bin/mount --bind "$DIR_IN" /IN && echo "$DIR_IN mounted"
        fi
    fi

    if [ "$(ls -A /OUT)" ]; then # dir is not empty
        if [ -f "/OUT/not_mounted" ]; then # if file "not_mounted" exists (dir /IN not mounted)
            /bin/mount --bind "$DIR_OUT" /OUT && echo "$DIR_OUT mounted"
        else
            echo "/OUT is already mounted."
        fi
    else # dir is empty
        /bin/touch /OUT/mounted_ 2> /dev/null  # trying to create file in /OUT
        if [ $? -eq 0 ]; then                  # if file created...
            echo "/OUT is already mounted."
        else
            /bin/umount /OUT
            /bin/mount --bind "$DIR_OUT" /OUT && echo "$DIR_OUT mounted"
        fi
    fi
else
    echo "Flashdrive is not mounted."
fi
