#!/bin/bash -i

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
    #SOURCE=ubuntu@laflordearagon.es:/home/ubuntu/temp/
    SOURCESFILE="$PWD/backups.config"
    # Where to store the incremental backups
    DESTBASE='/home/ubuntu/backup/backups'
    mkdir -p $DESTBASE
    LOGSDIR='/home/ubuntu/backup/logs'
    mkdir -p $LOGSDIR
}

function dispatch {
    # Recorremos el fichero línea a línea
    while read -r line
    do
        stringarray=($line) # Convierto la variable a string
        DOMAIN=${stringarray[0]}
        PORT=${stringarray[1]}
        DIR=${stringarray[2]}
        SOURCE="root@$DOMAIN:$DIR"
        # Creo el directorio de destino según el dominio de origen
        mkdir -p $DESTBASE/$DOMAIN
        lastbackup
        backup
    done < $SOURCESFILE
}

function lastbackup {
    # Backup de ayer
    YESTERDAY="$DESTBASE/$DOMAIN/$(date -d yesterday +%Y-%m-%d)/"
    # Donde guardamos el backup de hoy
    DEST="$DESTBASE/$DOMAIN/$(date +%Y-%m-%d)"
}

function backup {
    # Use yesterday's backup as the incremental base if it exists
    if [ -d "$YESTERDAY" ]
    then
        # Hard Links option
	    OPTS="--link-dest $YESTERDAY"
        echo "DEST: '$DEST'"
        echo "YESTERDAY: $YESTERDAY"
        echo "OPTS: $OPTS"
        
        rsync -azv -e "ssh -p $PORT" --link-dest $YESTERDAY $SOURCE $DEST
    else
        rsync -azv -e "ssh -p $PORT" $SOURCE $DEST
    fi
    echo "SSH: '$SSH'"
    echo "OPTS: '$OPTS'"
    echo "SOURCE: '$SOURCE'"
    echo "DEST: '$DEST'"
    # Run the rsync
    #rsync -azv -e "$SSH" "$OPTS" "$SOURCE" "$DEST"
    #rsync -azv "$OPTS" "$SOURCE" "$DEST"
    echo "===================================="
}

initVars
dispatch
# backup