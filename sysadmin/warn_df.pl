#!/usr/bin/perl

#@TITLE=Aquarion's Drive Space Warning System
#@DESC=Detect when the Drive Space is too low, and do things

# Usage: df -P /dev/hda1 | perl $HOME/bin/warn_df.pl || $HOME/bin/smsthis.pl "Atoll is running out of disk space"
# (smsthis.pl is a gateway to my bulksms.co.uk account, it sends a text message to me)
# (smsthis should be in the same place you got this from, 
# 
# This script runs every 5 minutes in my crontab.

# First line of input is crap
$foo = <STDIN>;

### Setup some variables

$waitfor = 60*45;# the 45 minute claim. Repeat warning each 45 mins
$warnat = 500; # Warn when the space < this # of megabytes
$now = time();
$file = $ENV{HOME}."/logs/spaceLog"; # The Logfile


### Get the stats of the logfile
# If the logfile has been modified (ie, there has been a warning issued
# in the last $waitfor seconds, we don't do anything.

($atime, $mtime) = (stat($file))[8,9];


### And now, the logic

if (($now-$mtime) > $waitfor) { # If we shouldn't send a message, don't do anything.

	### Grab free space
	# Yes, I could do this using a perl module instead of relying on df, 
	# but that means extra dependancies and having to load it at start time,
	# and would not be much quicker, really.
	$space = <STDIN>;

	chomp($space);

	#/dev/hda1             18868924  14189500   3720920  80% /
	$space =~ s/^(.*?) +(.*?) +(.*?) +(.*?) +(.*?) +(.*?)$/\4/;
	if ($space < $warnat*1000) { # If we have less than $warnat MB remaining
		#print "Oh No! ".$space."\n" ;
		print "Running out of space on drive!";
				open(LOGFILE,">".$file);
				print LOGFILE $now." Running low on space: ".$space."\n"; # Modify the log so we can check later
				close(LOGFILE);
		exit 1;
	} else {
	#	print "Plenty of space\n";
		exit 0;
	}

} else { # We've sent a message in the last $waitfor seconds.
	#print "Not testing for now - ".$now." - ".$mtime." = ".($now-$mtime)."\n";
	exit 0;
}


# The End. I'm sure there are better, more perlish ways of doing this, but I'm not
# a perl programmer. This is only released because it looked useful