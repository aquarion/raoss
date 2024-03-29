#!/bin/bash


set -o verbose  # Say what we're doing as we do it
set -o errexit  # Exit if any line fails
set -o pipefail # Exit if any piped command fails

trap 'echo "Aborting due to an error on $0 line $LINENO. Exit code: $?" >&2' ERR
set -o errtrace #Cascade that to all functions

export LANG=C
export LC_ALL=C
FILE=$1;
DIR="/Users/aquarion/Documents/Statements"
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

/usr/local/bin/terminal-notifier -message "Archived statement for $NAME" -title "Capital One"