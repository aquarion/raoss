#!/usr/bin/python
import sys,re

matches = ["hug", "snuggle", "glomp", "glomph", "cuddle", "ceilingdrop"]

lines = 0
huglines = 0

for line in sys.stdin:
	found = 0
	for word in matches:
		if line.find(word) != -1:
			#echo "found %s in %s" % word, line
			found = 1
	huglines += found
	lines += 1

print "%s,%s" % (lines,huglines)
