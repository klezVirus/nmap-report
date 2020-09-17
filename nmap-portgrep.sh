#!/bin/bash
if [[ "$1" == "" ]]
then 
	echo "Usage: nmap-portgrep filepath open|filtered|closed"

elif [[ "$(echo $2 | grep -P 'open|closed|filtered|all')" == "" ]]
	then
		echo "Usage: nmap-portgrep filepath open|filtered|closed|all"
else
	if [[ "$2" == "all" ]]
	then
	cat "$1" | grep -P "^\d{1,5}" | grep -P "open|closed" | awk -F "/" '{print $1}' | sort -u | sed "s/$/,/g" | tr -d "\n" | sed "s/,$//g"
	else
	cat "$1" | grep -P "^\d{1,5}" | grep -P "$2" | awk -F "/" '{print $1}' | sort -u  | sed "s/$/,/g" | tr -d "\n" | sed "s/,$//g"
	fi
fi
