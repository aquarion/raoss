#!/bin/bash

function uncommited {
	echo "Hello";
}

find -L $HOME/code -type d -name .git -exec $HOME/bin/uncommited-dir.sh {} \; | grep -v "File system loop detected"
