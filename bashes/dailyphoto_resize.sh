#!/bin/bash

if [ -z $1 ];
then
	export DIRECTORY="/home/aquarion/hosts/live.dailyphoto.aquarionics.com/htdocs"
else
	export DIRECTORY=$1
fi

echo "using $DIRECTORY"
sleep 4

 find $DIRECTORY -regextype posix-extended -name \*jpg -regex ".*\/[[:digit:]][[:digit:]]\.jpg" | while read input
 do
 	echo -n "Convert $input [";
 	for x in 600 900 1200 1800 2000;
 	do
 		output="${input}@${x}"
 		echo -n "$x:" 
 		if [ ! -e "${input}@${x}" ];
 		then
 			echo -n "R"
 			convert "${input}" -resize ${x}x  "${input}@${x}"
 			echo -n "G"
 			guetzli "$output" "$output"
 		else
 			echo -n "Exists"
 		fi
 		echo -n "|"
 	done
 	echo "!]"
 done
