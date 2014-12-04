#/bin/sh
REMOVE=$1

/etc/init.d/denyhosts stop

cd /var/lib/denyhosts
for THISFILE in hosts hosts-restricted hosts-root hosts-valid users-hosts;
do
mv $THISFILE /tmp/;
cat /tmp/$THISFILE | grep -v $REMOVE > $THISFILE;
rm /tmp/$THISFILE;
done;

mv /etc/hosts.deny /tmp/
cat /tmp/hosts.deny | grep -v $REMOVE > /etc/hosts.deny;
rm /tmp/hosts.deny

/etc/init.d/denyhosts start
