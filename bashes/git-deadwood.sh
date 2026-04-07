#!/bin/bash
# Deletes local branches already merged into main (or master), then prunes
# stale remote-tracking references with git fetch --prune.

COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_RESET='\033[0m'

GIT_ROOT=$(git rev-parse --show-toplevel)

if [ -z "$GIT_ROOT" ]; then
	echo -e "${COLOR_RED}You need to be in a git repo for this to have any hope of working${COLOR_RESET}"
	exit 1
fi

if [ "$(git rev-parse --verify main 2>/dev/null)" ]; then
	MAIN=main
elif [ "$(git rev-parse --verify master 2>/dev/null)" ]; then
	MAIN=master
else
	echo -e "${COLOR_RED}N\'eer main nor master branch here, I cannot help thee.${COLOR_RESET}"
	exit 5
fi

BRANCHES=$(git branch --merged=$MAIN | grep -v $MAIN)
if [[ $BRANCHES ]]; then
	echo -e "${COLOR_GREEN}Deleting local branches that have been merged into $MAIN${COLOR_RESET}"
	echo "$BRANCHES" | xargs git branch -d
fi

echo ""
echo -e "${COLOR_GREEN}Pruning locally tracked remote branches${COLOR_RESET}"
git fetch --prune


BRANCHES=$(git branch -vv | grep ': gone]' | awk '{print $1}')
if [[ $BRANCHES ]]; then
	echo -e "${COLOR_GREEN}Pruning local branches that have been merged into $MAIN and are tracking a remote branch that has been deleted${COLOR_RESET}"
	echo "$BRANCHES" | xargs git branch -d
fi