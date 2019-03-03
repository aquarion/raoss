#!/bin/bash

if [ -z $1 ];
then
	echo "usage: $0 FILENAME"
	exit 5
elif [ ! -f $1 ];
then
	echo "usage: $0 FILENAME [$1 not found]"
	exit 5
else
	export input=$1
fi


echo -n "Convert $input [";
for x in 600 900 1200 1800 2000;
do
	output="${input}@${x}"
	echo -n "$x:" 
	if [ ! -e "${input}@${x}" ];
	then
		echo -n "Resize:"
		convert "${input}" -resize ${x}x  "${input}@${x}"
		echo -n "Squish"
		guetzli "$output" "$output"
	else
		echo -n "Exists"
	fi
	echo -n "|"
done
echo "!]"

for x in 600 900 1200 1800 2000;
do
	cat <<-EOF

	@media (max-width: ${x}px) {
		body {
	    	background-image: url("${input}@${x}");
		}
	}
	EOF
done