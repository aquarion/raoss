#!/bin/bash

FILE=$1;
DIR="/Users/aquarion/Dropbox/Documents/Statements"
NAME=$(cat $FILE | tail -1 | cut -d, -f1 | cut -d/ -f2-3 | sed -e "s/\([[:digit:]]*\)\/\([[:digit:]]*\)/\2-\1/");
YEAR=$(echo $NAME | cut -d- -f1)
if [[ $FILE =~ "00097081" ]]; then
	DIR="$DIR/Current Account";
	QDIR="/Current Account";
elif [[ $FILE =~ "00933203" ]]; then
	DIR="$DIR/Cardcash Joint";
	QDIR="/Cardcash Joint";
else
	QDIR="/";
fi

if [[ ! -e "$DIR/$YEAR" ]];
then
	mkdir -p "$DIR/$YEAR";
fi

mv "$FILE" "$DIR/$YEAR/$NAME.csv"

echo mv "\"$FILE\" \"$DIR/$YEAR/$NAME.csv\"" > /dev/hazel_bank.log

~/Applications/terminal-notifier.app/Contents/MacOS/terminal-notifier -message "mv $FILE $DIR/$YEAR/$NAME.csv" -title "Hazel"