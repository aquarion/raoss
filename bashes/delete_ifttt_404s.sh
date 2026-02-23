#!/bin/bash

# If IFTTT.com gets a 404 on a "download image" trigger, it instead saves a custom "couldn't find that" image,
# This is bullshit, so this script finds those and nukes them from orbit by looking for files with the right
# Checksum, and then deleting them. MD5 is not cryptographically secure, but if somehow something manages to
# generate an md5 with the same value as their 404, by accident or malice, it deserves to be sent to the
# phantom zone. Don't run this on / just in case, though.
#
# This program deletes files. No warrenty is entered into. Caveat Clicktor.

# Find files | Get the MD5 for each | Filter for this checksum | delete all the things. Now with added Array Technology!

# This is for the old 404 image. - 394f8b4fa928b5f2d0c13645f99e2d33
# This is for the shiny new colourful one 96ff1cee0b824f18612629b4bcf24e91
# This is for the shiny new colourful one in png form 4d3559b444eb8d78b1a9e0ee15132434
# This is for the imgur one. 11c1b13ba973eef71dbfc66f95352f1d
# THis is for the IFTTT Logo one. 639499649961ccc250e200c17d7d797f

IMG404HASHES=(394f8b4fa928b5f2d0c13645f99e2d33 96ff1cee0b824f18612629b4bcf24e91 4d3559b444eb8d78b1a9e0ee15132434 11c1b13ba973eef71dbfc66f95352f1d 639499649961ccc250e200c17d7d797f)

# directories
LOCKDIR=/tmp

# Locking code based on code from http://troy.jdmz.net/cron/

# Originally by Troy Johnson,
# Adapted by Nicholas Avenell <nicholas@aquarionics.com> for lifestream.

# lock file creation and removal
LOCKFILE=$LOCKDIR/$(basename "$0").lock
[ -f "$LOCKFILE" ] && echo "$LOCKFILE" exists && exit 0
trap '{ rm -f "$LOCKFILE"; exit 255; }' 2
trap '{ rm -f "$LOCKFILE"; exit 255; }' 15
trap '{ rm -f "$LOCKFILE"; exit 0; }' EXIT
touch "$LOCKFILE"

if [[ -z $1 ]]; then
	echo "Finds broken IFTTT images and deletes them. Warning: Deletes things."
	echo "Usage: $0 [Directory]"
	exit 5
fi

# echo "Search $1 for broken files";

n=0
t=$(find "$1" -type f | wc -l)

find "$1" -type f | while read -r filename; do
	n=$((n + 1))
	MD5SUM=$(md5sum "$filename" | cut -d" " -f1)
	printf "%05d/%05d %-72s \033[0K\r" $n "$t" "$filename"
	if [[ " ${IMG404HASHES[*]} " == *" ${MD5SUM} "* ]]; then
		echo -e "\n $filename - $MD5SUM Deleted"
		rm "${filename}"
	fi
done
