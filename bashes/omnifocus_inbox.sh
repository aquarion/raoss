#!/bin/bash
OLD=${1}.old
cat "$1" | while read line;
do
	# echo $line
	osascript <<EOT
    tell application "OmniFocus"
      parse tasks into default document with transport text "$line //Alexa"
    end tell
EOT
done
echo `date >> "$OLD"`
cat "$1" >> "$OLD"
rm "$1"
