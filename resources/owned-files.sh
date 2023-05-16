#!/bin/bash

users=(
   "level00"
   "level01"
   "level02"
   "level03"
   "level04"
   "level05"
   "level06"
   "level07"
   "level08"
   "level09"
   "level10"
   "level11"
   "level12"
   "level13"
   "level14"
   "flag00"
   "flag01"
   "flag02"
   "flag03"
   "flag04"
   "flag05"
   "flag06"
   "flag07"
   "flag08"
   "flag09"
   "flag10"
   "flag11"
   "flag12"
   "flag13"
   "flag14"
)

# Iterate over each user and group
for user in "${users[@]}"; do
    echo "User: $user"

    # Find files and directories with user/group permissions
    find / -user "$user" -o -group "$user" 2>/dev/null

    echo
done
