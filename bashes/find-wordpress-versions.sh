#!/bin/bash
# Lists WordPress versions for all installations found under a given directory
# (default: current dir). Uses WP-CLI to retrieve the version of each install.

if [ -z "$1" ]; then
	searchdir='.'
else
	searchdir=$1
fi

echo "Looking in $(realpath "$searchdir")"

find -L "$searchdir" -name wp-settings.php -not -regex ".*archive.*" 2>/dev/null | while read -r linein; do
	DIR=$(dirname "$linein")
	VERSION=$(wp core version --path="$DIR" --allow-root)
	echo "$VERSION" at "$(realpath "$DIR")"
done | sort | uniq
