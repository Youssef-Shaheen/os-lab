#!/bin/bash

cd "$(dirname "$0")" || exit 1

sleep 23

main_dir="directory"
quarantine_dir="malicious_directory"
whitelist="whitelist.txt"

mkdir -p "$quarantine_dir"
touch "$whitelist"

for file in "$main_dir"/*
do
    if [ ! -f "$file" ]
    then
        continue
    fi

    name=$(basename "$file")

    if grep -Fxq "$name" "$whitelist"
    then
        continue
    fi

    malicious=0

    if [[ "$file" == *.exe || "$file" == *.bat || "$file" == *.vbs || "$file" == *.scr || "$file" == *.ps1 ]]
    then
        malicious=1
    fi

    if grep -Eqi 'virus|trojan|malware|worm|ransomware' "$file"
    then
        malicious=1
    fi

    if [ "$malicious" -eq 1 ]
    then
        if cp "$file" "$quarantine_dir/"
        then
            rm "$file"
            echo "$file is malicious and it is DELETED"
        fi
    fi
done
