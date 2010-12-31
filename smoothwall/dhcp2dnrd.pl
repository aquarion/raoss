#!/usr/bin/perl
#
# dhcp2dnrd.pl
#
# Author: Douglas E. Warner <silfreed@silfreed.net>
#         http://silfreed.net
#
#         Nicholas Avenell <nicholas@aquarionics.com>
#         http://www.aquarionics.com
#
# Purpose: read ips and names out of dhcpd.leases and 
#          add them to the /etc/hosts file, then restart
#          dnrd so we can have dns for all hosts being served
#          through dns
#
# License: MIT/X Consortium License
#
# Revisions:
#   v0.1.0
#   2001.05.01  Initial release.  Basic support for copying
#               files and info where they need to go.
#  
#  v0.1.1
#  2010.03.03   Modifications to support Smoothwall 3 by NA
#

BEGIN { $Class::Date::WARNINGS=0; }

# requires Class::Date
use Class::Date qw(date localdate gmdate now);


# configuration
$extendedhostname = ".robotdomain";
$hostspath = "/etc/hosts";
$dhcpdpath = "/usr/etc/dhcpd.leases";
$dhcpdconfpath = "/usr/etc/dhcpd.conf";

# main

# read in the hosts file
if (open(HOSTS, $hostspath)) {
	@hosts = <HOSTS>;
	close(HOSTS);
} else {
	print "ERROR: cannot open $hostspath\n";
	exit;
} # end if

# debug
#foreach $line (@hosts) {
#	print $line;
#} # end foreach
#print "\n";


# read dhcpd.leases file
if (open(DHCPD, $dhcpdpath)) {
	@dhcpd = <DHCPD>;
	close(DHCPD);
} else {
	print "ERROR: cannot open $dhpcdpath\n";
	exit;
} # end if

# debug
#foreach $line (@dhcpd) {
#	print $line;
#} # end foreach
#print "\n";


# read dhcpd.conf file
if (open(DHCPDCONF, $dhcpdconfpath)) {
	@dhcpdconf = <DHCPDCONF>;
	close(DHCPDCONF);
} else {
	print "ERROR: cannot open $dhcpdconfpath\n";
	exit;
} # end if

# debug
#foreach $line (@dhcpdconf) {
#	print $line;
#} # end foreach
#print "\n";


# get current dhcpd leases into @curr_leases
my @curr_leases;
$i = 0;
foreach $line (@dhcpd) {
	if ($line !~ /^#/ && $line !~ /^[\n]/) {
		if ($line =~ /lease/) {
			$ip = $1 if ($line =~ /lease\s(.*)\s{/);
			$curr_leases[$i][0] = $ip;
			#print $ip." ";
		} # end if
		if ($line =~ /ends/) {
			$enddatetime = $1 if ($line =~ /.*ends [0-9] (.*)\;/);
			$enddatetime =~ s/\//-/g;
			$curr_leases[$i][1] = $enddatetime;
			#print $enddatetime." ";
		} # end if
		if ($line =~ /client-hostname/) {
			$hostname = $1 if ($line =~ /.*client-hostname \"(.*)\"\;/);
			$curr_leases[$i][2] = $hostname;
			#print $hostname."\n";
			$i++;
		} # end if
	} # end if
} # end foreach

# debug
#print "printing \$curr_leases\n";
#for ($i = 0; $i < @curr_leases; $i++) {
#	print $curr_leases[$i][0]." ".$curr_leases[$i][1]." ".$curr_leases[$i][2]."\n";
#} # end foreach


# get static dhcpd leases into @static_leases
my @static_leases;
$i = 0;
foreach $line (@dhcpdconf) {
	if ($line !~ /^#/ && $line !~ /^[\n]/) {
		if ($line =~ /host/) {
			$ip = $1 if ($line =~ /.*fixed-address\s(.*?)\;/);
			$hostname = $1 if ($line =~ /.*option host-name \"(.*)\"\;/);
			$static_leases[$i][0] = $ip;
			$static_leases[$i][1] = $hostname;
			$i++;
		} # end if
	} # end if
} # end foreach


# debug
#print "printing \$static_leases\n";
#for ($i = 0; $i < @static_leases; $i++) {
#	print $static_leases[$i][0]." ".$static_leases[$i][1]."\n";
#} # end foreach


# pull out current dynamic leases into @now_leases
my @now_leases;
my $updated = 0;
for ($i = 0; $i < @curr_leases; $i++) {
	$updated = 0;
	if (@now_leases == 0) {
		push @now_leases, @curr_leases[$i];
		$updated = 1;
	} else {
		for ($j = 0; $j < @now_leases; $j++) {
			if ($now_leases[$j][0] eq $curr_leases[$i][0] && date($curr_leases[$i][1]) > date($now_leases[$j][1]))  {
				$now_leases[$j] = $curr_leases[$i];
				$updated = 1;
			} # end if
		} # end for
		if ($updated == 0) {
			push @now_leases, @curr_leases[$i];
		} # end if
	} # end if
} # end for

# debug
#print "printing \$now_leases\n"; 
#for ($i = 0; $i < @now_leases; $i++) { 
# 	print $now_leases[$i][0]." ".$now_leases[$i][1]." ".$now_leases[$i][2]."\n";
#} # end foreach 


# print new hosts file (for now)
if (open(NEW_HOSTS, ">$hostspath")) {
	my $fin = 0;
	foreach $line (@hosts) {
		if ($line !~ /^####dhcp2dnrd####/ && $line !~ /^####static leases####/ && $fin != 1) {
			print NEW_HOSTS $line;
		} else {
			$fin = 1;
} # end if
	} # end foreach
	
	print NEW_HOSTS "####dhcp2dnrd####\n";
	for ($i = 0; $i < @now_leases; $i++) {
		print NEW_HOSTS $now_leases[$i][0]."\t\t".$now_leases[$i][2]." ".$now_leases[$i][2].$extendedhostname."\n";
	} # end for
	
	print NEW_HOSTS "####static leases####\n";
	for ($i = 0; $i < @static_leases; $i++) {
		print NEW_HOSTS $static_leases[$i][0]."\t\t".$static_leases[$i][1]." ".$static_leases[$i][1].$extendedhostname."\n";
	} # end for
	close(NEW_HOSTS);
} else {
	print "ERROR: writing to $hostspath\n";
	exit;
} # end if


# restart dnrd
if (open(DNRDPID, "/var/run/dnsmasq.pid")) {
	@dnrdpid = <DNRDPID>;
} else {
	print "ERROR: reading /var/run/dnsmasq.pid";
	exit;
} # end if
$dnrdpid = $1 if ($dnrdpid[0] =~ /(.*)\n/);
#print $dnrdpid."\n";

system "kill $dnrdpid";
sleep 3;
system "/usr/bin/dnsmasq -r /etc/resolv.conf.dnsmasq"

