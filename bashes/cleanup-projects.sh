#!/bin/bash
# Iterates over subdirectories of the current directory, switches each git repo to
# main, pulls the latest changes, then prunes merged branches via git deadwood.

STARTING_DIRECTORY=$(realpath .)
MAXDEPTH=${1:-1}

echo "Starting cleanup of git projects in $STARTING_DIRECTORY with max depth of $MAXDEPTH"
find .  -maxdepth "$MAXDEPTH" -type d | while read -r DIR; do
	pushd "$DIR" || continue
	if [ -d .git ]; then
		git switch main &&
			git pull &&
			git deadwood
	fi
	popd || cd "$STARTING_DIRECTORY" || exit 5
done
