#!/usr/bin/perl
use Mail::Sender;
use Date::Parse;
use Mail::Header;

# @TITLE=Send warnings to users whose posts have hit "Failed.Messages" in leafnode

#
# Get the command line arguments.
#

die "Usage: $0 folderfile\n"
    unless @ARGV==1;

my $messagefile = shift @ARGV;

open(MESSAGE,"$messagefile") or
     die "Unable to open $messagefile:$!\n";
     $header = new Mail::Header \*MESSAGE;
     close(MESSAGE);

$subject = $header->get("Subject");

if ($header->get("X-Gateway")){
	$mailto = "news\@localhost";
} elsif ($header->get("Reply-To")) {
	$mailto = $header->get("Reply-To");
} else {
	$mailto = $header->get("From");
}

chomp($mailto);
chomp($subject);

$subject = "[FAIL] ".$subject."\n\n";

$body = "Your message with the above subject has hit failed.messages.\nShout at Aquarion if you don't know why and would like the\nmessage back. quoting ref: $messagefile\n\nIf you ignore this message, it'll be deleted in a couple of weeks\n\n-- \nfailnews.pl, aq+newsmaster@gkhs.net";

$sender = new Mail::Sender {smtp => 'localhost', from => 'aq+newsmaster@gkhs.net'};
$sender->MailFile({to => $mailto,
subject => $subject,
msg => $body,
file => $messagefile});
