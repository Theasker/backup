#!/bin/bash -i

function initVars {
    # Colors ----------
    red='\033[0;31m'
    green='\033[0;32m'
    yellow='\033[0;33m'
    blue='\033[0;34m'         # Blue
    purple='\033[0;35m'       # Purple
    cyan='\033[0;36m'         # Cyan
    grey="\033[0;37m"

    BBlack='\033[1;30m'       # Black
    BRed='\033[1;31m'         # Red
    BGreen='\033[1;32m'       # Green
    BYellow='\033[1;33m'      # Yellow
    BBlue='\033[1;34m'        # Blue
    BPurple='\033[1;35m'      # Purple
    BCyan='\033[1;36m'        # Cyan
    BWhite='\033[1;37m'       # White

    resetcolor='\033[0m' # No Color
    
    #----------------------
    export BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK=yes
    #export BORG_PASSCOMMAND='Theasker'
    export BORG_PASSPHRASE='Theasker'
    DATE=$(date +%Y-%m-%d_%H:%M:%S)
    SOURCESFILE="$PWD/backups.config"
    CONFIGFILE="$PWD/config.json"
    SSHFS_BASEMOUNT=$(jq -r .config.sshfsmount $CONFIGFILE)
    mkdir -p $SSHFS_BASEMOUNT
    NBACKUPS=$(grep -v '#.' backups.config | wc -l)
    # Borg backup repository
    REPOSITORY=$(jq -r .config.repository $CONFIGFILE)
    BORG_OPTIONS="--verbose --list --stats --show-rc --compression lz4 --exclude-caches --exclude 'home/*/.cache/*' --exclude 'var/tmp/*'"
    export BORG_REPO=$REPOSITORY
    # Inicializamos el repositorio, si ya está sólo avisará que ya está creado y no hará ninguna acción  
    borg init --encryption=none $REPOSITORY
}

# Old config file
function dispatch {
    # Lee el archivo de configuración
    COUNT=1
    while IFS= read -r line
    do
        # Jump line with #
        if [[ $line != '#'* ]]; then
            printf "line: $line\n"
            # line to array of stringarray
            IFS=',' read -ra stringarray <<< "$line" 
            # stringarray=($line) # Line to array
            DOMAIN=${stringarray[0]}
            PORT=${stringarray[1]}
            SOURCE=${stringarray[2]}
            echo "SOURCE: $SOURCE"
            
            BACKUPNAME="$DATE-$DOMAIN-$PORT"
            #backup
            COUNT=$((COUNT+1))
            echo "--------------"
        fi
    done < $SOURCESFILE
}

function dispachJson {
    # Check number of domains to make backup
    N_DOMAINS=$(jq -r '.backups[].Domain' $CONFIGFILE | wc -l)
    # Walk through all domains + port
    for ((i=0; i<$N_DOMAINS; i++));
    do
        DOMAIN=$(jq -r .backups[$i].domain $CONFIGFILE)
        PORT=$(jq -r .backups[$i].port $CONFIGFILE)
        BACKUPNAME="$DATE-$DOMAIN-$PORT"
        # Make target directory
        # TARGET=$DESTBASE/$DOMAIN-$PORT
        # echo "TARGET: $TARGET"
        #mkdir -p $TARGET
        LOGSDIR="$DESTBASE/logs/$DOMAIN-$PORT"
        #mkdir -p $LOGSDIR
        # Check number of folders in this domain to make backup
        N_FOLDERS=$(jq -r ".backups[$i].folders" $CONFIGFILE | wc -l)
        # Walk through all directories and save in a variable
        SOURCE=""
        for ((j=0;j<$N_FOLDERS;j++));
        do
            DIR=$(jq -r ".backups[$i].folders[$j]" $CONFIGFILE)
            # Check is not null
            if [[ $DIR != 'null' ]];then
                if [[ $j -eq 0 ]];then
                    SOURCE="$DIR"
                else
                    SOURCE="$SOURCE $DIR"
                fi
            fi
        done
        backup
    done
}

function backup {
    # Show the number of domain of total domains ( $((i+1) )
    echo -e "${BCyan}---> Backup ${resetcolor}${yellow}($((i+1))/$N_DOMAINS)${resetcolor} of ${green}$SOURCE ($DOMAIN:$PORT)${resetcolor}"
    # sshfs -p $PORT root@$DOMAIN:/ $SSHFS_BASEMOUNT -o allow_other -o ro
    sleep 1s
    ### Agrega al comienzo de cada path SSHFS_BASEMOUNT
    # echo "source antes: $SOURCE"
    SOURCE=$(echo "$SSHFS_BASEMOUNT${SOURCE// / $SSHFS_BASEMOUNT}")
    # echo "sources final: $SOURCE"
    echo -e "${BBlue}Borg command:${purple} borg create $BORG_OPTIONS $REPOSITORY::$BACKUPNAME $SOURCE ${resetcolor}"
    # borg create $BORG_OPTIONS $REPOSITORY::$BACKUPNAME $SOURCE
    echo -e "${BCyan}---> END Backup ${resetcolor}${yellow}($((i+1))/$N_DOMAINS)${resetcolor} of ${green}$SOURCE ($DOMAIN:$PORT)${resetcolor}\n"
    #umount $SSHFS_BASEMOUNT
}

function summary {
    echo -e "${yellow}---> SUMMARY -------------------------------------------${resetcolor}"
    echo -e "${green}-----> LIST OF BACKUPS -----------------------------------${resetcolor}"
    borg list --short $REPOSITORY
    echo -e "${yellow}-----> PRUNE -----------------------------------------${resetcolor}"
    borg prune -v --list $REPOSITORY --save-space --stats --show-rc --keep-minutely 4 
    borg compact $REPOSITORY
    echo -e "${yellow}---------------------------------------------------->${resetcolor}"
}

clear
initVars
#dispatch
dispachJson
#summary