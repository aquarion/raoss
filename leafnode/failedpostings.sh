#!/bin/sh

# @TITLE=Failed.messages warning (wrapper)
# @DESC=Execute perl script for failed messages

for a in /var/spool/news/failed.postings/*
do
	/root/bin/failnews.pl $a
	mv $a /var/spool/failed.archive
done;
