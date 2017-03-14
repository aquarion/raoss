#!/bin/bash +x
PASSWORD=$1
LOC=/var/www/db-backup/$2

mkdir -p $LOC

mysql -u root -p$PASSWORD -e 'show databases;' --skip-column-names --skip-pager | while read DATABASE; 
do 
	TMPFILE=`mktemp` || exit 1
	#echo $DATABASE;
	if [[ $DATABASE = performance_schema ]];
	then
		#echo "$DATABASE -eq performance_schema "
		continue;
	elif [[ $DATABASE = information_schema ]];
	then
		#echo "$DATABASE -eq information_schema"
		continue
	fi
	#aecho " ** $DATABASE";
	mysqldump --events -uroot -p$PASSWORD $DATABASE > $TMPFILE
	bzip2 -c $TMPFILE > $LOC/$DATABASE.sql.bz2
	rm $TMPFILE
done;
