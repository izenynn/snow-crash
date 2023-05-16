#!/usr/bin/env bash

# Install sshpass in linux:
# pacman -S sshpass

# Install sshpass on macos:
# brew install hudochenkov/sshpass/sshpass

if [[ -z "$1" ]]; then
    echo "Connects to the machine automatically with the user of the specified level" >&2
    echo "Usage: $0 LEVEL" >&2
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

sshpass -e ssh -p 4242 "$user"'@localhost'

exit 0
