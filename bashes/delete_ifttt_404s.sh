#!/bin/bash

# If IFTTT.com gets a 404 on a "download image" trigger, it instead saves a custom "couldn't find that" image,
# This is bullshit, so this script finds those and nukes them from orbit by looking for files with the right
# Checksum, and then deleting them. MD5 is not cryptographically secure, but if somehow something manages to
# generate an md5 with the same value as their 404, by accident or malice, it deserves to be sent to the 
# phantom zone. Don't run this on / just in case, though. 
#
# This program deletes files. No warrenty is entered into. Caveat Clicktor.

# Find files | Get the MD5 for each | Filter for this checksum | restrict the output to filenames | Put double-quotes around stuff for spaces | delete all the things.

# This is for the old 404 image.
find /home/aquarion/Dropbox/IFTTT/reddit -type f -exec md5sum {} + \
	| grep '^394f8b4fa928b5f2d0c13645f99e2d33' \
	| cut -d" " -f3-  \
	| sed 's/.*/"&"/' \
	| xargs -r rm 

# This is for the shiny new colourful one
find /home/aquarion/Dropbox/IFTTT/reddit -type f -exec md5sum {} + \
	| grep '^96ff1cee0b824f18612629b4bcf24e91' \
	| cut -d" " -f3-  \
	| sed 's/.*/"&"/' \
	| xargs -r rm 
