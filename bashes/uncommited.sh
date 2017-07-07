#!/bin/bash

find -L $HOME/code -type d -name .git -exec $HOME/bin/uncommited-dir.sh {} \; 2>&1 | grep -v "File system loop detected"
