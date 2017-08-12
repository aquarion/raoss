#!/bin/bash

if [ -z "$1" ]
then
	searchdir='.'
else
	searchdir=$1
fi

echo "Looking in `realpath $searchdir`"

find $searchdir -name wp-settings.php | while read linein
do
	echo Found $linein
	~/bin/wp core version --path="`dirname $linein`"
done