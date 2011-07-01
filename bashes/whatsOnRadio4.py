#!/usr/bin/python
import urllib
import xml.dom.minidom as minidom
import feed.date.rfc3339 as rfcdate
from datetime import datetime
import sys

timeinput = " ".join(sys.argv[1:])

#"2008-10-03 18:30:00+01:00"

timestamp = rfcdate.tf_from_timestamp(timeinput)

starttime = datetime.utcfromtimestamp(timestamp + 120.0).strftime("%Y-%m-%dT%H:%M:%SZ");
endtime   = datetime.utcfromtimestamp(timestamp + 140.0).strftime("%Y-%m-%dT%H:%M:%SZ");

url = 'http://www0.rdthdo.bbc.co.uk/cgi-perl/api/query.pl?method=bbc.schedule.getProgrammes&channel_id=,%s&start=%s&end=%s&limit=1'

sock = urllib.urlopen(url % ('BBCRFour', starttime, endtime));
data = sock.read();
doc = minidom.parseString(data);
doc.getElementsByTagName('programme')[0]
print doc.getElementsByTagName('programme')[0].attributes['title'].nodeValue
