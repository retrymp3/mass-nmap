#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <IP range>"
    exit 1
fi

ipRange="$1"
echo "Starting scanning of range: $ipRange"

parentDir=$(echo "$ipRange" | sed 's/\//_/g')

if [ -d "$parentDir" ]; then
    echo "Writing to $parentDir directory.."
else
    echo "Creating $parentDir directory.."
    mkdir $parentDir
fi

nmap -sL -n $ipRange | awk '/Nmap scan report/{print $NF}' >$parentDir/ipadds.txt

cat $parentDir/ipadds.txt | while read line 
do
    if sudo nmap -sn "$line" | grep -q "Host is up"; then
        echo "Creating directory: $line"
        mkdir -p "$parentDir/$line"

        sudo nmap -A -p- --max-retries 2 -v -T4 "$line" -oA "$parentDir/$line/nmap_output"
    else
        echo "Host is down, no ping: $line"
    fi
done