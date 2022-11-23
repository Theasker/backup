#!/bin/bash -i

function initVars {
    # Colors ----------
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    NC='\033[0m' # No Color
    #----------------------
    export BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK=yes
    #export BORG_PASSCOMMAND='Theasker'
    export BORG_PASSPHRASE='Theasker'
    DATE=$(date +%Y-%m-%d_%H:%M:%S)
    SOURCESFILE="$PWD/backups.config"
    SSH_BASEMOUNT="/mnt/sshfs"
    NBACKUPS=$(grep -v '#.' backups.config | wc -l)
    # Borg backup repository
    REPOSITORY="ssh://root@podereuropeo.duckdns.org:22/home/ubuntu/borgbackups"
    export BORG_REPO=$REPOSITORY
    # Inicializamos el repositorio, si ya está sólo avisará que ya está creado y no hará ninguna acción
    #borg init --encryption=none ubuntu@podereuropeo.duckdns.org:/home/ubuntu/borgbackups
}

function dispatch {
    # Lee el archivo de configuración
    COUNT=1
    while IFS= read -r line
    do
        # Jump line with #
        if [[ $line != '#'* ]]; then
            #printf "line: $line\n"
            # line to array of stringarray
            IFS=',' read -ra stringarray <<< "$line" 
            # stringarray=($line) # Line to array
            DOMAIN=${stringarray[0]}
            PORT=${stringarray[1]}
            SOURCE=${stringarray[2]}
            BORG_OPTIONS="--verbose --list --stats --show-rc --compression lz4 --exclude-caches --exclude 'home/*/.cache/*' --exclude 'var/tmp/*'"
            BACKUPNAME="$DATE-$DOMAIN-$PORT"
            backup
            COUNT=$((COUNT+1))
        fi
    done < $SOURCESFILE
}

function backup {
    echo -e "---> Backup ${YELLOW}($COUNT/$NBACKUPS)${NC} of ${GREEN}$SOURCE ($DOMAIN:$PORT)${NC}"
    sshfs -p $PORT root@$DOMAIN:/ $SSH_BASEMOUNT -o allow_other -o ro
    sleep 1s
    ### Agrega al comienzo de cada path SSH_BASEMOUNT
    SOURCE=$(echo "$SSH_BASEMOUNT${SOURCE// / $SSH_BASEMOUNT}")
    borg create $BORG_OPTIONS $REPOSITORY::$BACKUPNAME $SOURCE
    echo -e "---> END Backup of ${GREEN}$SOURCE ($DOMAIN:$PORT)${NC}"
    umount $SSH_BASEMOUNT    
}

function summary {
    echo -e "${YELLOW}---> SUMMARY -------------------------------------------${NC}"
    echo -e "${YELLOW}-----> PRUNE -----------------------------------------${NC}"
    borg prune -v --list $REPOSITORY --show-rc --keep-hourly 4 
    borg compact $REPOSITORY
    echo -e "${YELLOW}-----> LIST -----------------------------------------${NC}"
    borg list $REPOSITORY
}

initVars
dispatch
summary