#!/bin/bash

timeout .1 bash -c 'cat < /dev/null > /dev/tcp/localhost/52698'
echo $?
echo $SUBL_DETECT

if [[ $( timeout .1 bash -c 'cat < /dev/null > /dev/tcp/localhost/52698' && echo true ) == 'true' ]]
then
	subl $@
else
	vim $@
fi

