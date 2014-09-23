#!/usr/bin/perl

use strict;
use warnings;

use lib qw(. /usr/local/cpanel/3rdparty/perl/514/lib64/perl5/cpanel_lib/);

use CGI;
use JSON;
use File::Find::Rule;
use File::Slurp;

our $VERSION = '0.1';
our $NAME = 'cMailPro TroubleShooter CG helper API';

our $queue_dir = "/var/CommuniGate/Queue/";

sub main {
    my $q = CGI->new;

    my $remote_addr = $q->remote_addr();
    if ($remote_addr ne '[127.0.0.1]' && 
	$remote_addr ne '[77.71.117.10]') {
	return;
    }

    my $render_data ; 
    my $path = $q->path_info;

    if (!$path || $path =~ m/^\/$/) {
	$render_data = { api => $NAME, api_version => $VERSION }; 
    } elsif ($path =~ m/messages(\/)*$/) {
	$render_data = messages();
    } elsif (my @captured = $path =~ m/messages\/(.*)$/) { 
	my $message = $captured[0];

	$render_data = message($message);
    }

    render($q, $render_data);
}

# https://IP:port/cgi/this.cgi/message/<msg_id>
sub message {
    my $message = shift;

    my @file = File::Find::Rule->file()->name($message.".msg")->in($queue_dir);
    if ($file[0]) {
	my @data = read_file($file[0]);

	return { message => \@data };
    }

    return {};
}

# https://IP:port/cgi/this.cgi/messages
sub messages {

    my @files = sort(File::Find::Rule->file()->name("*.msg")->in($queue_dir));
    my @messages;

    foreach my $f (@files) {
	my ($from, $to, $subject, $date);

	open (my $FH, "<", $f);

	if ($FH) {

	    my $count = 0;

	    while (my $line = <$FH>) {
		$count++;
		chomp $line;
		my @captures = $line =~ m/^Subject:(.*)/;

		$subject = $captures[0] unless !$captures[0];

		@captures = $line =~ m/^From:(.*)/;
		$from = $captures[0]  unless !$captures[0];
	

		@captures = $line =~ m/^To:(.*)/;
		$to = $captures[0]  unless !$captures[0];

		@captures = $line =~ m/^Date:(.*)/;
		$date = $captures[0]  unless !$captures[0];

		if ($count >= 30 || 
		    ($to && $from && $subject && $date)) {
		    last;
		}
	    }
	    
	    close($FH);
	}

	$f =~ s/$queue_dir//;
	$f =~ s/\.msg//;

	push @messages, { 
	    date => $date,
	    id => $f,
	    to => $to,
	    from => $from,
	    subject => $subject
	};
    }

    return { messages => \@messages };
}

sub render {
    my $q = shift;
    my $render = shift || {  };

    print $q->header(-type=> "application/json", -charset=>"UTF-8");   

    printf to_json($render);
    printf "\n";
}

main();

