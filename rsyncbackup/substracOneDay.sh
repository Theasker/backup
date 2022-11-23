#!/bin/bash

BASEDIR='/home/ubuntu/backup/backups'
cd $1

for f in *; do
    if [ -d "$f" ]; then
        AYER=$(date -d "$f-1 days" +"%Y-%m-%d")
        mv $f $AYER
        echo "$f -> $AYER"
    fi
done