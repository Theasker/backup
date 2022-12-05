#!/bin/bash

clear
CONFIGFILE="$PWD/config.json"
DESTBASE="$PWD/backups"
# Check number of domains to make backup
N_DOMAINS=$(jq -r '.backups[].Domain' $CONFIGFILE | wc -l)
# Walk through all domains + port
for ((i=0; i<$N_DOMAINS; i++));
do
    DOMAIN=$(jq -r .backups[$i].Domain $CONFIGFILE)
    echo $DOMAIN
    PORT=$(jq -r .backups[$i].Port $CONFIGFILE)
    # Make target directory
    TARGET=$DESTBASE/$DOMAIN-$PORT
    mkdir -p $TARGET
    LOGSDIR="$DESTBASE/logs/$DOMAIN-$PORT"
    mkdir -p $LOGSDIR
    # Check number of folders in this domain to make backup
    N_FOLDERS=$(jq -r ".backups[$i].Folders" $CONFIGFILE | wc -l)
    # Walk through all directories
    for ((j=0;j<$N_FOLDERS;j++));
    do
        DIR=$(jq -r ".backups[$i].Folders[$j]" $CONFIGFILE)
        # Check is not null
        if [[ $DIR != 'null' ]];
        then
            SOURCE="root@$DOMAIN:$DIR"
        fi
    done
done

exit 0