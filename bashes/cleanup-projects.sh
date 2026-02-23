#!/bin/bash

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
