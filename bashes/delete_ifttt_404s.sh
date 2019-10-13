#!/bin/bash

# If IFTTT.com gets a 404 on a "download image" trigger, it instead saves a custom "couldn't find that" image,
# This is bullshit, so this script finds those and nukes them from orbit by looking for files with the right
# Checksum, and then deleting them. MD5 is not cryptographically secure, but if somehow something manages to
# generate an md5 with the same value as their 404, by accident or malice, it deserves to be sent to the 
# phantom zone. Don't run this on / just in case, though. 
#
# This program deletes files. No warrenty is entered into. Caveat Clicktor.

# Find files | Get the MD5 for each | Filter for this checksum | restrict the output to filenames | Put double-quotes around stuff for spaces | delete all the things.

TMPFILE=`tempfile`

find /home/aquarion/Dropbox/IFTTT/reddit -type f -exec md5sum {} + > $TMPFILE

# This is for the old 404 image.
cat $TMPFILE \
	| grep '^394f8b4fa928b5f2d0c13645f99e2d33' \
	| cut -d" " -f3-  \
	| sed 's/.*/"&"/' \
	| xargs -r rm -v 

# This is for the shiny new colourful one
cat $TMPFILE \
	| grep '^96ff1cee0b824f18612629b4bcf24e91' \
	| cut -d" " -f3-  \
	| sed 's/.*/"&"/' \
	| xargs -r rm -v

# This is for the shiny new colourful one in png form
cat $TMPFILE \
	| grep '^4d3559b444eb8d78b1a9e0ee15132434' \
	| cut -d" " -f3-  \
	| sed 's/.*/"&"/' \
	| xargs -r rm -v

rm $TMPFILE