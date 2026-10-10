#!/bin/bash

if [ "$#" -ne 2 ]
then
    echo "enter 2 arguments"
    exit 1
fi

main_dir=$1
quarantine_dir=$2
whitelist="whitelist.txt"
touch "$whitelist"

if [ ! -d "$main_dir" ] || [ ! -d "$quarantine_dir" ]
then
    echo "Directory does not exist"
    exit 1
fi

shopt -s nullglob

while true
do
    files=("$quarantine_dir"/*)

    if [ "${#files[@]}" -eq 0 ]
    then
        echo "No malicious files to review."
        exit 0
    fi

    echo "Choose a file:"

    for ((i=0; i<${#files[@]}; i++))
    do
        name=$(basename "${files[$i]}")
        echo "$((i+1)): $name"
    done

    read -p "> " choice

    if ! [[ "$choice" =~ ^[0-9]+$ ]]
    then
        echo "Invalid choice"
        continue
    fi

    if [ "$choice" -lt 1 ] || [ "$choice" -gt "${#files[@]}" ]
    then
        echo "Invalid choice"
        continue
    fi

    selected="${files[$((choice-1))]}"
    name=$(basename "$selected")

    echo "For $name:"
    echo "1: Restore this file back into dir (it was a false positive)"
    echo "2: Permanently delete this file from malicious_dir (it was genuinely malicious)"
    echo "3: Go back"

    read -p "> " action

    if [ "$action" = "1" ]
then
    if cp "$selected" "$main_dir/"
    then
        if ! grep -Fxq "$name" "$whitelist"
        then
            echo "$name" >> "$whitelist"
        fi

        rm "$selected"
        echo "Restored $name to $main_dir."
    fi

    elif [ "$action" = "2" ]
    then
        if rm "$selected"
        then
            echo "$name permanently deleted."
        fi

    elif [ "$action" = "3" ]
    then
        continue

    else
        echo "Invalid choice"
    fi
done
