#!/bin/bash

if [ -z "$1" ]
then
	searchdir='.'
else
	searchdir=$1
fi

CURRENT=`curl -s https://api.wordpress.org/core/version-check/1.7/ | jq -r .offers[0].current`

echo "Looking in `realpath $searchdir`"

find -L . -name wp-settings.php -not -regex ".*vault.*" -not -regex ".*archive.*" -exec realpath "{}" \; 2> /dev/null | sort | uniq | while read linein
do
	DIR=`dirname $linein`
	echo -n `realpath $DIR`
	VERSION=`wp core version --path="$DIR" --allow-root`
	echo -n " is $VERSION"
	
	pushd $DIR > /dev/null
	OWNER=`stat -c '%U' wp-config.php`
	sudo chown -R $OWNER:www-data .
	echo -n "   ... [Core|"
	sudo -u $OWNER wp core update | ts >> upgrade.log && \
		echo -n "Plugins|" && sudo -u $OWNER wp plugin update --all | ts >> upgrade.log && \
		echo -n "Themes|" && sudo -u $OWNER wp theme update --all | ts >> upgrade.log && \
		echo -n "Plugin Lang|" && sudo -u $OWNER wp language plugin --all update | ts >> upgrade.log && \
		#echo -n "Network|" && sudo -u $OWNER wp core update-db --network | ts >> upgrade.log && \
		echo -n "Theme Lang" && sudo -u $OWNER wp language theme --all update | ts >> upgrade.log 
		wp config has MULTISITE && echo -n "|Network" && sudo -u $OWNER wp core update-db --network | ts >> upgrade.log
		echo "]";
	popd > /dev/null
	#fi
done
