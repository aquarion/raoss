#!/bin/bash

if [[ ! -f ~/.postmark_api_key ]]
then
	echo "Please put a Postmark API key in ~/.postmark_api_key"
	exit 5
fi

source ~/.postmark_api_key

POSTMARK_SETTINGS='{"enabled":1,"api_key":"'$POSTMARK_API_KEY'","stream_name":"outbound","sender_address":"support@istic.net","force_from":1,"force_html":0,"track_opens":0,"track_links":0,"enable_logs":1}';

if [ -z "$1" ]
then
	searchdir='.'
else
	searchdir=$1
fi

function displayName {
	if ! command -v figlet >/dev/null 2>&1
	then
		echo $1
		echo ---------
	else
		figlet "$1"
	fi

}

function updatePostmarkSettings {
	OWNER=$1
	sudo -u $OWNER wp plugin install postmark-approved-wordpress-plugin --force --activate
	if [[ $(wp config has MULTISITE && wp config get MULTISITE) == 1 ]]; then
		sudo -u $OWNER wp site list --field=url --archived=false | while read URL; 
		do
			figlet -f "small" `wp option get blogname --url=$URL`
			sudo -u $OWNER wp option set postmark_settings "$POSTMARK_SETTINGS" --url=$URL; 
		done
	else
		sudo -u $OWNER wp option set postmark_settings "$POSTMARK_SETTINGS"
	fi
}

CURRENT=`curl -s https://api.wordpress.org/core/version-check/1.7/ | jq -r .offers[0].current`

echo "Looking in `realpath $searchdir`"

find -L . -name wp-settings.php -not -regex ".*vault.*" -not -regex ".*archive.*" -exec realpath "{}" \; 2> /dev/null | sort | uniq | while read linein
do
	DIR=`dirname $linein`
	VERSION=`wp core version --path="$DIR" --allow-root`
	pushd $DIR > /dev/null
	OWNER=`stat -c '%U' wp-config.php`
	SITENAME=`wp option get blogname`
	displayName "$SITENAME"

	echo -n `realpath $DIR`
	echo " is $VERSION"

	echo -n " .. Working as $OWNER .. "
	sudo chown -R $OWNER:www-data .
	sudo -u $OWNER touch upgrade.log
	sudo chmod o+w upgrade.log
	updatePostmarkSettings $OWNER | ts >> upgrade.log
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
