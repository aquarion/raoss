#!/bin/bash

export REALLYDELETE=false
export SEARCHPATH=$PWD


while [[ $# > 1 ]]
do
key="$1"
echo $key
case $key in
    -y|--really-delete)
    export REALLYDELETE=true
    #shift # past argument
    ;;
    -s|--searchpath)
    SEARCHPATH="$2"
    shift # past argument
    ;;
    -l|--lib)
    LIBPATH="$2"
    shift # past argument
    ;;
    --default)
    DEFAULT=YES
    ;;
    *)
            # unknown option
    ;;
esac
shift
done

echo $REALLYDELETE

if [[ $REALLYDELETE == true ]];
then
	echo "Really Delete"
else
	echo "Don't really delete"
fi

find "$SEARCHPATH" -maxdepth 1 -mindepth 1 -type d | while read directory
do
	echo "Searching $directory"
	find "$directory" -type f \
		\( -iname "*.mkv" -o -iname "*.mp4" -o -iname "*.avi" -o -iname "*.mpg" \) \
	 	-printf "%f\n" \
		| sed 's/\.[^\.]*$//' \
		| uniq -c | sort -n \
		| while read duplicates
	do
		COUNT=`echo $duplicates | cut -d' ' -f1`
		FILES=`echo $duplicates | cut -d' ' -f2-`
		if [[ $COUNT -lt 2 ]];
		then
			#echo $FILES;
			#echo No duplicates found.
			continue
		fi
		echo "--> ($COUNT) $FILES";
		find "$directory" -iname "*$FILES*" \! -iname "*srt" -printf "%p (%kk)\n"
		if [[ $REALLYDELETE == true ]];
		then
			find "$directory" -iname "*$FILES*" \! -iname "*srt" -print0 -quit | xargs -0tI '{}' echo rm "{}" 
		else
			find "$directory" -iname "*$FILES*" \! -iname "*srt" -print0 -quit | xargs -0tI '{}' rm "{}" 
		fi
	done
done
