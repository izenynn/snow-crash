#!/usr/bin/env bash

if [[ -z "$1" || -z "$2" ]]; then
    echo "Sends a file to the machine '/dev/shm' directory" >&2
    echo "Usage: $0 LEVEL LOCAL_FILE" >&2
    exit 1
fi

user="level$(printf %02d $1)"

if [[ "$1" -eq "0" || "$1" -eq "00" ]]; then
    export SSHPASS="$user"
else
    previous_level=$((10#$1 - 1))
    previous_user="level$(printf %02d $previous_level)"
    flag_file="../$previous_user/flag"
    if [[ ! -f "$flag_file" ]]; then
        echo "Error: flag file $flag_file not found" >&2
        exit 1
    fi
    export SSHPASS=$(cat "$flag_file")
fi

sshpass -e scp -P 4242 "$2" "$user"'@localhost:/dev/shm'

exit 0
