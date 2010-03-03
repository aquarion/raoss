#!/usr/bin/perl

#@TITLE=Aquarion's Load Average Warning System
#@DESC=Detect when the Load Average is too high, and do things

# Usage: perl $HOME/bin/warn_load.pl || $HOME/bin/smsthis.pl "Atoll is overloaded"
# (smsthis.pl is a gateway to my bulksms.co.uk account, it sends a text message to me)
# (smsthis should be in the same place you got this from, 
# 
# This script runs every 5 minutes in my crontab.


### Setup some variables

$waitfor = 60*45;# the 45 minute claim. Repeat warning each 45 mins
$warnat = 10; # Warn when the load > this
$now = time();

### Grab load average over 15 minutes.
# Yes, I could do this using a perl module instead of relying on /proc, 
# but that means extra dependancies and having to load it at start time,
# and would not be much quicker, really.

open(LOADAVERAGE,"</proc/loadavg");
$load = <LOADAVERAGE>;
chomp($load);
#0.00 0.04 0.03 1/80 1859
$load =~ s/^(.*?) +(.*?) +(.*?) +(.*?) +(.*?)$/\3/;


### Get the stats of the logfile
# If the logfile has been modified (ie, there has been a warning issued
# in the last $waitfor seconds, we don't do anything.

$file = $ENV{HOME}."/.loadLog";
($atime, $mtime) = (stat($file))[8,9];


### And now, the logic

if (($now-$mtime) > $waitfor) { # If we shouldn't send a message, don't do anything.
	if ($load > $warnat) { # She canna take any more, capt'n
		print $ENV{HOSTNAME}." is overloaded\n";
			open(LOGFILE,">".$file);
			print LOGFILE $now." Overloaded\n"; # Modify the log so we can check later
			close(LOGFILE);
		exit 1;
	} else {
		exit 0;
	}
} else { # We've sent a message in the last $waitfor seconds.
	#print "Not testing for now - ".$now." - ".$mtime." = ".($now-$mtime)."\n";
	exit 0;
}


# The End. I'm sure there are better, more perlish ways of doing this, but I'm not
# a perl programmer. This is only released because it looked useful