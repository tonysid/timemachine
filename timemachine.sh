#!/bin/bash
SERVER=
SCREEN=:0
EXCLUDEFILE=~/.rsync_excludes
DESTINATION=/root/timemachine

function opentimemachine {
HOME=/root
echo HOME = $HOME
mkdir $DESTINATION 2> /dev/null
BACKUPDIR=/
EXCLUDEFILE=$HOME/.rsync_excludes
echo Mounting $DESTINATION.
mount $DESTINATION
}

function closetimemachine {
HOME=/root
echo HOME = $HOME
echo Unmounting $DESTINATION.
umount $DESTINATION
rmdir $DESTINATION 2> /dev/null
}


if [[ "$UID" == "0" ]]
then
    echo "User is root"
    #HOME=/$USER

    if [[ "$1" == "restore" ]]
    then
    opentimemachine; \
        rsync -rvc --delete \
            --exclude-from=$EXCLUDEFILE \
            --exclude=$DESTINATION \
            --delete-excluded \
            $2 /
        echo System restored to $2
        exit
    fi


else
    echo "User is not root"
    HOME=/home/$USER
    DESTINATION=$HOME/home_backup
    BACKUPDIR=$HOME/
    echo "Restarting with sudo"
    sudo $0
    exit
fi
if [ $SERVER ]
then
    DESTINATION=$USER@$SERVER:$DESTINATION
fi

date=`date "+%Y-%m-%dT%H_%M_%S"`

if [[ "$1" == "compare" ]]
then
    echo Comparing with most recent backup.
    touch $DESTINATION/latest
	opentimemachine && \
    rsync -rvnc --delete \
        --exclude-from=$EXCLUDEFILE \
        --exclude=$DESTINATION \
        --delete-excluded \
        $BACKUPDIR $DESTINATION/latest
elif [[ "$1" == "open" ]]
then
    opentimemachine
    cd $DESTINATION
    ls --color
    exit
elif [[ "$1" == "close" ]]
then
    closetimemachine
    exit
elif [ "$#" -ne 0 ]
then
    echo
    echo Invalid command.
else

PID="`ps -u $USER | grep timemachine.sh | awk '{print $1}' | head -1`"
NORMAL_USER=`users | awk '{print $1}'`

su $NORMAL_USER -c "'Starting full rsync backup. ( PID $PID ) '" 

echo Starting backup at $date. | mail -s "rsync backup started (PID $PID)" root

	opentimemachine
    echo $PID > $HOME/.timemachine.pid
    rsync -azP \
        -h \
        -i \
        --quiet \
        --log-file=$DESTINATION/backup-$date.log \
        --exclude-from=$EXCLUDEFILE \
        --exclude=$DESTINATION \
        --delete-excluded \
        --link-dest=$DESTINATION/latest \
        --max-size='100K' \
        --stats \
        $BACKUPDIR $DESTINATION/incomplete_back-$date && \
        mv $DESTINATION/incomplete_back-$date $DESTINATION/backup-$date && \
        if [ -e $DESTINATION/latest ]
        then
            rm $DESTINATION/latest
        fi && \
            ln -f -s backup-$date $DESTINATION/latest && \
            ( echo Backed up to $DESTINATION && echo && echo Contents of backup-$date.log && \
            grep -v .Private $DESTINATION/backup-$date.log && echo && ( ls -alFth $DESTINATION | head -5 ) ) | mail -s "rsync backup complete" root && \
            su -c "Backup complete." `echo $HOME | sed 's/.*\/*\///'` || \
            notify-send "The time machine failed."
        echo Exiting time machine.

        rm $HOME/.timemachine.pid


    fi
    if [[ "$USER" == "root" ]]
    then
        echo Unmounting $DESTINATION.
        umount $DESTINATION && rmdir $DESTINATION
    fi
