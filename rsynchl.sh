#!/bin/bash -i

#==============================================================================
# title: ScriptBackup.sh
# description:  Automatic Backup Script in Bash Shell
# author: Mauricio Segura Ariño
# date: 20220915
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
    DESTBASE="$PWD/backups"
    mkdir -p $DESTBASE
    LOGSDIR="$DESTBASE/logs"
    mkdir -p $LOGSDIR
}

function dispatch {
    # Recorremos el fichero línea a línea
    while read -r line
    do
        # Compruebo que la línea de configuración contiene "#"
        if [[ $line != *"#"* ]]; then
            stringarray=($line) # Convierto la variable en un array
            DOMAIN=${stringarray[0]}
            PORT=${stringarray[1]}
            DIR=${stringarray[2]}
            SOURCE="root@$DOMAIN:$DIR"
            # Creo el directorio de destino según el dominio de origen
            TARGET=$DESTBASE/$DOMAIN$PORT
            LOGSDIR="$DESTBASE/logs/$DOMAIN$PORT"
            mkdir -p $TARGET
            lastbackup
            backup
        fi

        
    done < $SOURCESFILE
}

function lastbackup {
    # Backup de ayer
    #YESTERDAY="$DESTBASE/$DOMAIN/$(date -d yesterday +%Y-%m-%d)/"
    # Backup anterior
    #LASTBACKUP="$DESTBASE/$DOMAIN/$(ls -trq $DESTBASE/$DOMAIN | tail -n1)"
    LASTBACKUP="$TARGET/$(ls -trq $TARGET | tail -n1)"
    # Donde guardamos el backup de hoy
    DEST="$TARGET/$(date +%Y-%m-%d)"
    LOGSFILE="$LOGSDIR/$(date +%Y-%m-%d).log"
}

function backup {
    # Use yesterday's backup as the incremental base if it exists
    if [ -d "$LASTBACKUP" ]
    then
        # Hard Links option
	    OPTS="--link-dest $LASTBACKUP"
        rsync -azvv -e "ssh -p $PORT" --link-dest $LASTBACKUP $SOURCE $DEST >> $LOGSFILE
    else
        rsync -azvv -e "ssh -p $PORT" $SOURCE $DEST >> $LOGSFILE
    fi
    echo "===================================="
}

initVars
dispatch