#!/usr/bin/env bash

if [[ -z "$1" ]] || [[ -z "$2" ]]; then
    echo "Error: not enought arguments" &1>2
    echo "Usage: $0 LEVEL LOCAL_FILE" &1>2
    exit 1
fi

user="level$1"

export SSHPASS="$user"
sshpass -e scp -P 4242 "$2" "$user"'@localhost:/dev/shm'

exit 0
