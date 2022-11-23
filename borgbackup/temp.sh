#!/bin/bash
SOURCE="/home/ubuntu/.ssh /home/ubuntu/temp"
SSH_BASEMOUNT="/mnt/sshfs"

#echo "uno  dos  tres" | sed -e 's/^/##/g' | sed -e 's/  /  ##/g'
#echo $SOURCE | sed -e 's/^/##/g' | sed -e 's/  /  ##/g'
var=$(echo "$SSH_BASEMOUNT${SOURCE// / $SSH_BASEMOUNT}")
echo $var