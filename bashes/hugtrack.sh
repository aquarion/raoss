#!.bin/bash

find ~/irclogs/ -name \#maelfroth.20\* | while read line;
do
	date=`echo $line | cut -d. -f 2`
	last=`echo $line | cut -d. -f 4`
	#if [[ $last = "bz2" ]];then
		#echo "BZ2"
		#hugs=$(bzcat $line | hugtrack.py)
	#else
		#echo "Not"
		#hugs=$(hugtrack.py < $line)
	#fi
	#echo $line = $last
	#echo $date,$hugs
	echo $date $line
done
