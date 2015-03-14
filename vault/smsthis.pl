#!/usr/bin/perl
use LWP::Simple;

#@TITLE = Bulksms.co.uk interface
#@DESC = Send SMS messages though BulkSMS

#Usage: smsthis.pl "Send this message" [phone number]

# EG:
#	Send cryptic message to default phone number:
#	smsthis.pl "The Matrix has you" 

#	Send cryptic message to Dana Scully's Landline :
#	smsthis.pl "This will really bake your noodle" 555-1013

#	(How do I know Dana Scully's landline? 
#				The internet is a strange and powerful thing)

# This is a procmail script to make it forward messages to your phone:

## Begin Procmail
#SUBJECT=`formail -xSubject:` 
#:0 c
#* (MATCHING CRITERIA)
#| ~/bin/smsthis.pl "$SUBJECT" >> ~/logs/sms.log
## End Procmail



$username = "";
$password = "";
$defaultPhone = "";
$messageclass = 2; # By default, be a cheapskate


### Logic Begins Here

$url = $ARGV[0];
if (!$ARGV[1]){
	$number = $defaultPhone;
} else {
	$number = $ARGV[1];
}
#print "Before encoding: $url\n";
$url =~ s/([^\w\-\.\@])/EncodeChar($1)/eg;
#print "After encoding: $url\n";


sub EncodeChar($) {
	my ($foo) = @_;
	return ($foo eq " ") ? "+" : "%" . sprintf "%lx", ord($foo);
}

$request = "http://www.bulksms.co.uk:5567/eapi/submission/send_sms/1/current?username=".$username
	."&password=".$password
	."&message=".$url
	."&msisdn=".$number
	."&msg_class=".$messageclass;

print get($request);

#print $request;
