#!/bin/bash

if [ -z "$1" ]
then
	searchdir='.'
else
	searchdir=$1
fi

echo "Looking in `realpath $searchdir`"

find -L $searchdir -name wp-settings.php -not -regex ".*archive.*" 2> /dev/null | while read linein
do
	DIR=`dirname $linein`
	VERSION=`wp core version --path="$DIR" --allow-root`
	echo $VERSION at `realpath $DIR`
done | sort | uniq
