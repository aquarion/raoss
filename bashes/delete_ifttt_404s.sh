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

IMG404HASHES=( 394f8b4fa928b5f2d0c13645f99e2d33 96ff1cee0b824f18612629b4bcf24e91 4d3559b444eb8d78b1a9e0ee15132434 11c1b13ba973eef71dbfc66f95352f1d 639499649961ccc250e200c17d7d797f )

if [[ -z $1 ]];
then
	echo "Finds broken IFTTT images and deletes them. Warning: Deletes things."
	echo "Usage: $0 [Directory]"
	exit 5
fi

# echo "Search $1 for broken files";

find "$1" -type f | while read filename
do
	MD5SUM=`md5sum "$filename" | cut -d" " -f1`
	if [[ " ${IMG404HASHES[@]} " =~ " ${MD5SUM} " ]]; then
	    # echo $filename - $MD5SUM;
	    rm "${filename}";
	fi
done