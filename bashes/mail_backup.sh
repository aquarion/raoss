#bin/bash

# directories
LOCKDIR=/tmp

# Locking code based on code from http://troy.jdmz.net/cron/

# Originally by Troy Johnson,
# Adapted by Nicholas Avenell <nicholas@aquarionics.com> for lifestream.

# lock file creation and removal
LOCKFILE=$LOCKDIR/`basename $0`.lock
[ -f $LOCKFILE ] && echo $LOCKFILE exists && exit 0
trap "{ rm -f $LOCKFILE; exit 255; }" 2
trap "{ rm -f $LOCKFILE; exit 255; }" 9
trap "{ rm -f $LOCKFILE; exit 255; }" 15
trap "{ rm -f $LOCKFILE; exit 0; }" EXIT
touch $LOCKFILE

getmail -qr /home/aquarion/.getmail/getmail.aquarionics
getmail -qr /home/aquarion/.getmail/getmail.istic
getmail -qr /home/aquarion/.getmail/getmail.hardwick

# IMPORTANT: Run this first in a terminal or ssh session to go though the oauth keys
# before you add it to cron.
