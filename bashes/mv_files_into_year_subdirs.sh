#!/bin/bash

for y in `seq 2010 $(date +%Y --date="1 year ago")`; 
do 
	mkdir -p $y; 
	find . -maxdepth 1 -type f -newermt "$y-01-01" ! -newermt "$y-12-31 23:59" -exec mv "{}" $y/ \;;
done
