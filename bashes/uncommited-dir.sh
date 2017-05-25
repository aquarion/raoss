#!/bin/bash

GITPATH=$1
DIRNAME=`dirname $1`
REPONAME=`basename $DIRNAME`
TMPFILE=`mktemp -t uncommited.XXXXXXXXXX`
HOSTNAME=`hostname -s`

cd $DIRNAME;

if [[ -e .uncommitted-ignore ]];then
	exit
fi

FLAG=`git status 2> /dev/null | grep -c : | awk '{if ($1 > 0) printf "%s", "DIRTY"; else printf "%s", "CLEAN"}'`
PUSH=`git-push --dry-run 2>&1`

if [[ $? -ne 0 ]]
then
	PUSH="NOUPSTREAM"
elif [[ "$PUSH" = "Everything up-to-date" ]]
then
	PUSH="UPTODATE"
else
	PUSH="UNCOMMITED"
fi

if [[ $FLAG = "DIRTY" ]]
then
	echo -e "$REPONAME\n---------------------------------------------------------------\n\n" > $TMPFILE
	echo -e "$DIRNAME\n\n" >> $TMPFILE
	git status 2>&1  1>> $TMPFILE
	cat $TMPFILE | mail -s "[$HOSTNAME] Uncommited stuff in $REPONAME" aquarion@localhost

elif [[ $PUSH = "UNCOMMITED" ]]
then
	echo -e "$REPONAME\n---------------------------------------------------------------\n\n" > $TMPFILE
	echo -e "$DIRNAME\n\n" >> $TMPFILE
	echo "has some unpushed stuff" 2>&1  1>> $TMPFILE
	cat $TMPFILE | mail -s "[$HOSTNAME] Unpushed stuff in $REPONAME" aquarion@localhost
fi

rm $TMPFILE;
