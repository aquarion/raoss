#!/bin/bash

source ~/.bash_profile

if [[ ! -e "$1" ]]
then
  echo File not supplied
	exit 7
fi

while read p; do
  echo $p
  task $p
done <"$1"

cat "$1" >> "$1.old"
echo "" > "$1"
