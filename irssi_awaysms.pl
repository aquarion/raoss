# IRSSI script to send AwayLog messages to an SMS number

#use strict;
use vars qw($VERSION %IRSSI);

use LWP::Simple;

use Irssi;
$VERSION = '0.2';
%IRSSI = (
   authors      => 'Aquarion',
   contact      => 'nicholas@istic.net',
   name         => 'awaysms',
   description  => 'Send Awaylog to SMS',
   modules      => '',
   license      => 'GNU GPL v2',
   url          => 'http://istic.net',
   changed      => '16 January 2012 09:11:48'
);

use Irssi::TextUI;

our $cnt = 0;
our $fname = undef();

Irssi::settings_add_str('awaysms', 'sms_username', '');
Irssi::settings_add_str('awaysms', 'sms_password', '');
Irssi::settings_add_str('awaysms', 'sms_number', '');
Irssi::settings_add_str('awaysms', 'sms_messageclass', 2);


sub awaysms ($$) {
   my ($sbitem, $get_size_only) = @_;
   unless ( $cnt )
   {
      $sbitem->{min_size} = $sbitem->{max_size} = 0 if ( ref $sbitem );
      return;
   }
   my $format = sprintf('{sb \%%yawaylog\%%n %d}', $cnt);
   $sbitem->default_handler($get_size_only, $format, undef, 1);
}

sub smsthis{
	my($username)     = Irssi::settings_get_str('sms_username');
	my($password)     = Irssi::settings_get_str('sms_password');
	my($number)       = Irssi::settings_get_str('sms_number');
	my($messageclass) = Irssi::settings_get_str('sms_messageclass');

	my($words) = @_;

	if (not defined $messageclass) {
		$messageclass = 2; # By default, be a cheapskate
	}

	if (not defined $username or not defined $password or not defined $number) {
		Irssi::print("username or password or number are not set!");
		return;
	}
	
	$words = Irssi::strip_codes($words);

	$words =~ s/([^\w\-\.\@])/EncodeChar($1)/eg;

	my($request) = "http://www.bulksms.co.uk:5567/eapi/submission/send_sms/1/current?username=".$username
		."&password=".$password
		."&message=".$words
		."&msisdn=".$number
		."&msg_class=".$messageclass;

	print "[AwaySMS] Sent SMS";
	get($request);

}

sub EncodeChar($) {
	my ($foo) = @_;
	return ($foo eq " ") ? "+" : "%" . sprintf "%lx", ord($foo);
}

Irssi::signal_add( 'log started' => sub {
   my $logfile = Irssi::settings_get_str( 'awaylog_file' );
   return unless ( $_[0]->{fname} eq $logfile );
   ($fname, $cnt) = ($logfile, 0);
});

Irssi::signal_add( 'log stopped' => sub {
   return unless ( $_[0]->{fname} eq $fname );
   ($cnt, $fname) = (0, undef);
});
		
Irssi::signal_add( 'log written' => sub {
   return unless ( $_[0]->{fname} eq $fname );
   $cnt++;

   if ($cnt < 20) {
		smsthis($_[1]);
   } elsif ($cnt == 20) {
		smsthis('Last SMS:'.$_[1]);
   }
   
});

Irssi::command_bind smsthis => sub {
	$_=join(" ",$_[0]);
	print $_;
	smsthis($_);
};