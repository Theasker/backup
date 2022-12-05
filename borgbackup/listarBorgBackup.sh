#!/bin/bash

CONFIGFILE="$PWD/config.json"
REPOSITORY=$(jq -r .config.repository $CONFIGFILE)
echo "Repositorio: $REPOSITORY"

echo "borg list $REPOSITORY"