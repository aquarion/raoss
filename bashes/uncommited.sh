#!/bin/bash

function uncommited {
	echo "Hello";
}

find $HOME -type d -name .git -exec $HOME/bin/uncommited-dir.sh {} \;
