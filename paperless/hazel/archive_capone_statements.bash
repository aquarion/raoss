#!/bin/bash

export LANG=C
FILE=$1;
DIR="/Users/aquarion/Dropbox (Personal)/Documents/Statements"
NAME=$(cat $FILE | tail -1 | cut -d, -f1 | cut -d/ -f2-3 | sed -e "s/\([[:digit:]]*\)\/\([[:digit:]]*\)/\2-\1/");
YEAR=$(echo $NAME | cut -d- -f1)
# if [[ $FILE =~ "00097081" ]]; then
# 	DIR="$DIR/Current Account";
# 	QDIR="/Current Account";
# elif [[ $FILE =~ "00933203" ]]; then
# 	DIR="$DIR/Cardcash Joint";
# 	QDIR="/Cardcash Joint";
# else
# 	QDIR="/";
# fi
QDIR="/Capital One";
DIR="$DIR/Capital One";

if [[ ! -e "$DIR/$YEAR" ]];
then
	mkdir -p "$DIR/$YEAR";
fi

mv "$FILE" "$DIR/$YEAR/$NAME.csv"

echo mv "\"$FILE\" \"$DIR/$YEAR/$NAME.csv\""

terminal-notifier -message "$NAME" -title "Hazel"