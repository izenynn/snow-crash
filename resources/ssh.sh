#!/usr/bin/env bash

# Install sshpass in linux:
# pacman -S sshpass

# Install sshpass on macos:
# brew install hudochenkov/sshpass/sshpass

if [[ -z "$1" ]]; then
    echo "Error: not enought arguments" &1>2
    echo "Usage: $0 LEVEL" &1>2
    exit 1
fi

user="level$1"

export SSHPASS="$user"
sshpass -e ssh -p 4242 "$user"'@localhost'

exit 0
