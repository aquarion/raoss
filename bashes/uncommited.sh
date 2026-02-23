#!/bin/bash
# Scans git repositories under a given directory (default: ~/code/) and reports
# any that have uncommitted changes or unpushed commits.

if [[ -z $1 ]]; then
	CODEDIR=$HOME/code/
else
	CODEDIR=$1
fi

function process_dir {
	DIRNAME=$(dirname "$1")
	REPONAME=$(basename "$DIRNAME")
	TMPFILE=$(mktemp -t uncommited.XXXXXXXXXX)
	HOSTNAME=$(hostname -s)

	cd "$DIRNAME" || return

	if [[ -e .uncommitted-ignore ]]; then
		exit
	fi

	FLAG=$(git status 2>/dev/null | grep -c : | awk '{if ($1 > 0) printf "%s", "DIRTY"; else printf "%s", "CLEAN"}')
	if ! PUSH=$(git-push --dry-run 2>&1); then
		PUSH="NOUPSTREAM"
	elif [[ "$PUSH" = "Everything up-to-date" ]]; then
		PUSH="UPTODATE"
	else
		PUSH="UNCOMMITED"
	fi

	#DEBUG# echo $DIRNAME is $FLAG

	if [[ $FLAG = "DIRTY" ]]; then
		{
			echo -e "\n---------------------------------------------------------------"
			echo -e "[$HOSTNAME] $REPONAME\n---------------------------------------------------------------\n\n"
			echo -e "$DIRNAME\n\n"
			git status 2>&1
		} >"$TMPFILE"
		cat "$TMPFILE"

	elif [[ $PUSH = "UNCOMMITED" ]]; then
		{
			echo -e "\n---------------------------------------------------------------"
			echo -e "[$HOSTNAME] $REPONAME\n---------------------------------------------------------------\n\n"
			echo -e "$DIRNAME\n\n"
			echo "has some unpushed stuff"
		} >"$TMPFILE"
		cat "$TMPFILE"
	fi

	rm "$TMPFILE"

}

find -L "$CODEDIR" -type d -name .git | while read -r directory; do
	# echo $directory
	process_dir "$directory"
done
