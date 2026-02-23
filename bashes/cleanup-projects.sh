#!/bin/bash
# Iterates over subdirectories of the current directory, switches each git repo to
# main, pulls the latest changes, then prunes merged branches via git deadwood.

STARTING_DIRECTORY=$(realpath .)

find . -type d -maxdepth 1 | while read -r DIR; do
	pushd "$DIR" || continue
	if [ -d .git ]; then
		git switch main &&
			git pull &&
			git deadwood
	fi
	popd || cd "$STARTING_DIRECTORY" || exit 5
done
