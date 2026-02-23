#!/bin/bash +x
# Dumps all MySQL databases (excluding performance_schema and information_schema)
# to bzip2-compressed SQL files in the specified backup directory.
# Usage: mysql_backup.sh <root-password> <backup-subdir>

PASSWORD=$1
LOC=/var/www/db-backup/$2

mkdir -p "$LOC"

mysql -u root -p"$PASSWORD" -e 'show databases;' --skip-column-names --skip-pager | while read -r DATABASE; do
	TMPFILE=$(mktemp) || exit 1
	#echo $DATABASE;
	if [[ $DATABASE = performance_schema ]]; then
		#echo "$DATABASE -eq performance_schema "
		continue
	elif [[ $DATABASE = information_schema ]]; then
		#echo "$DATABASE -eq information_schema"
		continue
	fi
	#aecho " ** $DATABASE";
	mysqldump --events -uroot -p"$PASSWORD" "$DATABASE" >"$TMPFILE"
	bzip2 -c "$TMPFILE" >"$LOC/$DATABASE.sql.bz2"
	rm "$TMPFILE"
done
