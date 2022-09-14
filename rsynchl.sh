#!/bin/bash

#==============================================================================
# title: ScriptBackup.sh
# description:  Automatic Backup Script in Bash Shell
# author: Mauricio Segura Ariño
# date: 20220920
# usage:    Create external file with the source directories
#           bash ScriptBackup.sh
# notes: Configure the initVars function and init de variables
# bash_version: 5.1.16(1)-release
#==============================================================================


function initVars {
    # The source path to backup. Can be local or remote.
    SOURCE=ubuntu@laflordearagon.es:/home/ubuntu/temp/
    # Where to store the incremental backups
    DESTBASE=/home/ubuntu/backup/backups
    # Where to store today's backup
    DEST="$DESTBASE/$(date +%Y-%m-%d)"
    # Where to find yesterday's backup
    YESTERDAY="$DESTBASE/$(date -d yesterday +%Y-%m-%d)/"
    LOGSDIR=/home/ubuntu/backup/logs
}

function makeDirs {
	# It Check if the application directories exist
	if [ ! -d $DESTBASE ]; then echo "Creo el directorio $DIRBACKUP"; mkdir -p $DESTBASE; fi
	if [ ! -d $LOGSDIR ]; then echo "Creo el directorio $LOGSDIR"; mkdir -p $LOGSDIR; fi
}

function dispatch {
    echo "dispath function"
}

function backup {
    # Use yesterday's backup as the incremental base if it exists
    if [ -d "$YESTERDAY" ]
    then
        # Hard Links option
	    OPTS="--link-dest $YESTERDAY"
    fi
     
    # Run the rsync
    rsync -azv -e 'ssh -p 22' $OPTS "$SOURCE" "$DEST"
}

initVars
makeDirs
dispatch
backup