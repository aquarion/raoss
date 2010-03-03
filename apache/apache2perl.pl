#!/usr/bin/perl

#@TITLE=Send Apache Logs to a MySQL table.
# Usage: @reboot tail -f /var/log/apache/access.log | /path/to/apache2perl

use DBD::mysql;

#Database options:
$dbUser = "aquarion";
$dbPass = ""; # Your password here
$dbName = "epistula";

$database = DBI->connect("dbi:mysql:$dbName:localhost:1114", $dbUser, $dbPass);

#204.95.98.252 - - [24/Dec/2003:15:23:38 +0000] "GET /archive/writing/2003/08/19 HTTP/1.0" 200 11873 "-" "msnbot/0.11 (+http://search.msn.com/msnbot.htm)"

while (<>) {
  my ($client, $identuser, $authuser, $date, $method,
      $url, $protocol, $status, $bytes, $referer,$agent) =
	
/^(\S+) (\S+) (\S+) \[(.*?)\] "(\S+) (.*?) (\S+)" (\S+) (\S+) "(.*?)" "(.*?)"$/;
  # ...
	#$database->quote($thisdir);
	$q = "insert into apachelogs (remote_host, remote_user, request_time, request_method, request_uri, request_protocol, status, bytes_sent, referer, agent) 
	values 
	(".$database->quote($client).", ".$database->quote($authuser).", '".$date."', ".$database->quote($method).", ".$database->quote($url).", ".$database->quote($protocol).", ".$database->quote($status).", ".$database->quote($bytes).", ".$database->quote($referer).", ".$database->quote($agent).")";

	print $database->quote($url)."\n";
	my $sth = $database->prepare($q);
	$sth->execute();

}
