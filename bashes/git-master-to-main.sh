#!/bin/sh
# Renames the master branch to main. You need to do this on the origin first
git branch -m master main
git fetch origin
git branch -u origin/main main
git remote set-head origin -a
