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
	echo -n `realpath $DIR`
	VERSION=`wp core version --path="$DIR" --allow-root`
	echo -n " is $VERSION"
	if [[ $VERSION == $CURRENT ]];
	then
	#	echo " -- No Upgrade Required"
	#else
		echo " -- Upgrade Required to $CURRENT"
		pushd $DIR > /dev/null
		OWNER=`stat -c '%U' wp-config.php`
		sudo chown -R $OWNER:www-data .
		echo -n "   ... [Core|"
		sudo -u $OWNER wp core update | ts >> upgrade.log && \
			echo -n "Plugins|" && sudo -u $OWNER wp plugin update --all | ts >> upgrade.log && \
			echo -n "Themes|" && sudo -u $OWNER wp theme update --all | ts >> upgrade.log && \
			echo -n "Plugin Lang|" && sudo -u $OWNER wp language plugin --all update | ts >> upgrade.log && \
			echo "Theme Lang]" && sudo -u $OWNER wp language theme --all update | ts >> upgrade.log 
		popd > /dev/null
	fi
done
