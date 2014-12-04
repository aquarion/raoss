#!/bin/bash

function uncommited {
	echo "Hello";
}

find -L $HOME/projects -type d -name .git -exec $HOME/bin/uncommited-dir.sh {} \;
