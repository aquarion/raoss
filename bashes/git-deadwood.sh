#!/bin/bash

GIT_ROOT=$(git rev-parse --show-toplevel)

if [ -z "$GIT_ROOT" ]; then
  echo "You need to be in a git repo for this to have any hope of working"
  exit 1
fi

if [ `git rev-parse --verify main 2>/dev/null` ]
then
   MAIN=main
elif [ `git rev-parse --verify master 2>/dev/null` ]
then
   MAIN=master
else
   echo N\'eer main nor master branch here, I cannot help thee.
   exit 5
fi
echo "Deleting local branches:"
BRANCHES=`git branch --merged=$MAIN | grep -v $MAIN`
if [[ $BRANCHES ]]
then
	git branch -d $(git branch --merged=$MAIN | grep -v $MAIN)
else
	echo ' - Nothing to delete'
fi
echo ""
echo "Pruning remote branches"
git fetch --prune
