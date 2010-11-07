#!/usr/bin/python

# Sorry, this is hackerware to a large extent, and no support is offered.
# Feel free to file bugs in https://github.com/aquarion/roass/issues

import feedparser # from http://www.feedparser.org/
import tumblr # from http://code.google.com/p/python-tumblr/


import os, time,sys,codecs,datetime, urlparse

sys.stdout = codecs.getwriter('utf8')(sys.stdout)

TWITTER_USERNAME = "aquarion"
BLOG= # Your tumblr url, quoted
USER= # Your username, quoted
PASSWORD= # Your tumblr Password, quoted
TIMECACHE="/var/cache/aquarion/lastime.cache"; # You need to create and have write permissions to this.

############## SETUP INSTRUCTIONS:
# 
#  Fill in the things above,
# 
#  echo 0 > to wherever you put TIMECACHE
#
#  Put it in Cron and forget about it.
#
################################################

FAVOURITES = "http://twitter.com/favorites/%s.rss" % TWITTER_USERNAME;



f = open(TIMECACHE, "r")
lasttime = f.read(128);
f.close();

highest = lasttime;

api = tumblr.Api(BLOG,USER,PASSWORD)

fp = feedparser.parse(FAVOURITES)

for i in range(len(fp['entries'])):
  item = fp['entries'][i]
  
  datetime = time.mktime(item['updated_parsed'])
  
  if int(datetime) > int(lasttime):
    #print tweet
    tweet = item['title'].split(": ")[1]
    user = item['title'].split(": ")[0]
    link= item['link']
    
    source = '<a href="%s">@%s</a>' % (link, user)
    
    post = api.write_quote(tweet,source)
    if int(datetime) > int(highest):
      highest = datetime;


f = open(TIMECACHE, "w")
f.write(str(int(highest)))
f.close();
