#!/bin/bash

MYHOME=`dirname $(realpath $0)`

find -L $HOME/code -type d -name .git -exec $MYHOME/uncommited-dir.sh {} \; 2>&1 | grep -v "File system loop detected"
