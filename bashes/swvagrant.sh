#!/bin/bash
#
# For repositories that store their vagrant files in a "./vagrant" directory of root
# this can be run at any point in the repository file structure to run vagrant commands
#

GITDIR=$(git rev-parse --show-cdup)
if [[ -z "$GITDIR" ]];
then
	GITDIR=.
fi
pushd $GITDIR/vagrant
vagrant $@
popd
