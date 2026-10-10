#!/bin/bash

if [ "$#" -ne 3 ]
then
    echo "enter 3 arguments"
    exit 1
fi

main_dir=$1
quarantine_dir=$2
time=$3

whitelist="whitelist.txt"
touch "$whitelist"

if [ ! -d "$main_dir" ]
then
    echo "Source directory does not exist"
    exit 1
fi

mkdir -p "$quarantine_dir"

if ! [[ "$time" =~ ^[1-9][0-9]*$ ]]
then
    echo "Interval must be a positive number"
    exit 1
fi

scan_files()
{
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
                echo "$file is malicious and it is DELETED"
                rm "$file"
            fi
        fi
    done
}

scan_files

ls -l "$main_dir" > directory-info.last

while true
do
    sleep "$time"

    ls -l "$main_dir" > directory-info.new

    if ! cmp -s directory-info.last directory-info.new
    then
        scan_files
        ls -l "$main_dir" > directory-info.last
    fi
done
