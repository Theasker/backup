#!/bin/bash -i

#==============================================================================
# title: ScriptBackup.sh
# description:  Automatic Backup Script in Bash Shell
# author: Mauricio Segura Ariño
# date: 20220915
# usage:    Create external file with the source directories
#           bash ScriptBackup.sh
# notes: 
#    Configure the initVars function and init de variables
#    Fill the config file with the source to backup
# bash_version: 5.1.16(1)-release
#==============================================================================

function initVars {
    # Variables SOURCESFILE y DESTBASE
    SOURCESFILE="$PWD/backups.config"
    # Backup target
    DESTBASE="$PWD/backups"
    # ================================================
    mkdir -p $DESTBASE
    LOGSDIR="$DESTBASE/logs"
    mkdir -p $LOGSDIR
}

function dispatch {
    # Read the config file with the domains, folders and ports.
    while read -r line
    do
        # Jump line with #
        if [[ $line != *"#"* ]]; then
            stringarray=($line) # Line to array
            DOMAIN=${stringarray[0]}
            PORT=${stringarray[1]}
            DIR=${stringarray[2]}
            SOURCE="root@$DOMAIN:$DIR"
            # Make target directory
            TARGET=$DESTBASE/$DOMAIN-$PORT
            mkdir -p $TARGET
            LOGSDIR="$DESTBASE/logs/$DOMAIN-$PORT"
            mkdir -p $LOGSDIR
            lastbackup
            backup
        fi
    done < $SOURCESFILE
}

function lastbackup {
    # Yesterday Backup
    #YESTERDAY="$DESTBASE/$DOMAIN/$(date -d yesterday +%Y-%m-%d)/"
    # Back Backup
    #LASTBACKUP="$DESTBASE/$DOMAIN/$(ls -trq $DESTBASE/$DOMAIN | tail -n1)"
    # Find the last backup
    LASTBACKUP="$TARGET/$(ls -trq $TARGET | tail -n1)"
    echo $LASTBACKUP
    # Today backup
    DEST="$TARGET/$(date +%Y-%m-%d)"
    LOGSFILE="$LOGSDIR/$(date +%Y-%m-%d).log"
}

function backup {
    # Use yesterday's backup as the incremental base if it exists
    printf "<--- Begin backup of $SOURCE (port: $PORT) $(date +%Y-%m-%d) --->\n"
    printf "\n<--- Begin backup of $SOURCE (port: $PORT) $(date +%Y-%m-%d) --->\n" >> $LOGSFILE
    if [ -d "$LASTBACKUP" ] # If exists
    then # $LASTBACKUP exists
        # Hard Links option
	    OPTS="--link-dest $LASTBACKUP"
        printf "Incremental backup en ...\n"
        #rsync -azv -e "ssh -p $PORT" --link-dest $LASTBACKUP $SOURCE $DEST >> $LOGSFILE
        rsync -azv -e "ssh -p $PORT" --link-dest $LASTBACKUP $SOURCE $DEST
    else # $LASTBACKUP not exists
        #rsync -azv -e "ssh -p $PORT" $SOURCE $DEST >> $LOGSFILE
        #rsync -azv -e "ssh -p $PORT" $SOURCE $DEST
        echo "No existe"
    fi
    printf "<--- END Backup of $SOURCE (port: $PORT) --->\n\n"
    printf "<--- END backup of $SOURCE (port: $PORT) --->\n\n" >> $LOGSFILE
}

initVars
dispatch