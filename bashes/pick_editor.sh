#!/bin/bash
# Opens files in Sublime Text if its rsub/rmate port (52698) is reachable on
# localhost, otherwise falls back to vim.

timeout .1 bash -c 'cat < /dev/null > /dev/tcp/localhost/52698'
echo $?
echo "$SUBL_DETECT"

if [[ $(timeout .1 bash -c 'cat < /dev/null > /dev/tcp/localhost/52698' && echo true) == 'true' ]]; then
	subl "$@"
else
	vim "$@"
fi
