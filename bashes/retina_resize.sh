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


WEBP="${1%.*}".webp
if [ ! -e "${WEBP}" ];
then
	echo "Creating webp version of $1"
	convert "${input}" -quality 50 -define webp:lossless=true "${WEBP}"
fi

echo -n "Convert $input [";
for x in 600 900 1200 1800 2000;
do
	output="${input}@${x}"
	echo -n "$x:"
	if [ ! -e "${input}@${x}" ];
	then
		echo -n "R"
		convert "${input}" -resize ${x}x  "${input}@${x}"
		echo -n "J"
		guetzli "$output" "$output"
	else
		echo -n "j"
	fi

	if [ ! -e "${WEBP}@${x}" ];
	then
		echo -n "W"
		convert "${input}" -quality 50 -define webp:lossless=true -resize ${x}x "${WEBP}@${x}" 
	else
		echo -n "w"
	fi
	echo -n "|"
done
echo "!]"

# for x in 600 900 1200 1800 2000;
# do
# 	cat <<-EOF

# 	@media (max-width: ${x}px) {
# 		body {
# 	    	background-image: url("${input}@${x}");
# 		}
# 	}
# 	EOF
# done
