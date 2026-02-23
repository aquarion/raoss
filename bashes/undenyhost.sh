#!/bin/sh
# Removes a specified host from all denyhosts deny lists and /etc/hosts.deny,
# then restarts the denyhosts service. Usage: undenyhost.sh <host-or-ip>

REMOVE=$1

/etc/init.d/denyhosts stop

cd /var/lib/denyhosts || exit
for THISFILE in hosts hosts-restricted hosts-root hosts-valid users-hosts; do
	mv $THISFILE /tmp/
	cat /tmp/$THISFILE | grep -v "$REMOVE" >$THISFILE
	rm /tmp/$THISFILE
done

mv /etc/hosts.deny /tmp/
cat /tmp/hosts.deny | grep -v "$REMOVE" >/etc/hosts.deny
rm /tmp/hosts.deny

/etc/init.d/denyhosts start
