#!/bin/bash

if [ -z "$1" ]
then
	searchdir='.'
else
	searchdir=$1
fi

CURRENT=`curl -s https://api.wordpress.org/core/version-check/1.7/ | jq -r .offers[0].current`

echo "Looking in `realpath $searchdir`"

find -L $searchdir -name wp-settings.php -not -regex ".*archive.*" 2> /dev/null | while read linein
do
	DIR=`dirname $linein`
	VERSION=`wp core version --path="$DIR" --allow-root`
	echo -n $VERSION at `realpath $DIR`
	if [[ $VERSION == $CURRENT ]];
	then
		echo " -- No Upgrade Required"
	else
		echo " -- Upgrade Required to $CURRENT" 
	fi
done | sort | uniq
