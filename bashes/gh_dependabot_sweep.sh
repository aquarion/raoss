#!/bin/bash

SLEEPFOR=10;

# send all output though ts to get timestamps for logging
COLOUR_RED='\033[0;31m'
COLOUR_GREEN='\033[0;32m'
COLOUR_YELLOW='\033[0;33m'
COLOR_RESET='\033[0m'

exec > >(ts '[%Y-%m-%d %H:%M:%S]')
exec 2>&1

function approve_and_merge_pr() {
	local REPO="$1"
	local PR="$2"
	echo -e "${COLOUR_RED}Approving and merging PR #$PR in repository $REPO${COLOR_RESET}";
	echo -e "${COLOUR_YELLOW}Approving and merging PR #$PR${COLOR_RESET}";
	LOOP_COUNT=0;
	OUT=1;
	while [ $OUT -ne 0 ]; do
		gh --repo="$REPO" pr review "$PR" --approve; 
		gh --repo="$REPO" pr merge "$PR" --auto --merge

		OUT=$?;
		LOOP_COUNT=$((LOOP_COUNT+1));
		if [ $LOOP_COUNT -gt 5 ]; then
			echo -e "${COLOUR_RED}Failed to approve and merge PR #$PR after 5 attempts. Skipping.${COLOR_RESET}";
			break;
		fi
		
		for _seq in $(seq 1 $SLEEPFOR); do
			echo -n ".";
			sleep 1;
		done;
		echo "!";

	done;
}

function list_and_merge_prs() {
	local REPO="$1"
	echo -e "${COLOUR_GREEN}Listing PRs for repository $REPO${COLOR_RESET}";
	gh pr list --repo "$REPO" --author "dependabot[bot]" | cut -f1 | while read -r PR; do
		approve_and_merge_pr "$REPO" "$PR";
	done;
}

function list_and_merge_all_prs() {
	ORGANIZATION=$1
	echo -e "${COLOUR_GREEN}Listing all repositories in organization $ORGANIZATION${COLOR_RESET}";
	gh repo list "$ORGANIZATION" --limit 1000 --no-archived | cut -f1 | while read -r REPO; do
		list_and_merge_prs "$REPO";
	done;
}

if [ "$#" -ne 1 ]; then
	echo "Usage: $0 <github-organization>";
	exit 1;
fi

list_and_merge_all_prs "$1";
