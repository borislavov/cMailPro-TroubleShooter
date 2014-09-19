package cMailPro::TroubleShooter::Model::CommuniGate::CLI;
use strict;
use warnings;

use Class::C3::Adopt::NEXT;

use CLI;
use Data::Dumper;
use Catalyst::Log;

use base qw(Catalyst::Model Class::Accessor);

__PACKAGE__->mk_accessors(qw|PeerAddr PeerPort SecureLogin login password|);

our $VERSION='0.2';

=head1 NAME

cMailPro::TroubleShooter::Model::CommuniGate::CLI - Catalyst Model

=head1 DESCRIPTION

Catalyst Model for CommuniGate's CLI interface.

=head1 new

=cut

sub new {
  my $self = shift;
  
  $self = $self->next::method(@_);
  $self->PeerAddr($self->PeerAddr || '127.0.0.1');
  $self->PeerPort($self->PeerPort || 106);
  $self->SecureLogin($self->SecureLogin || 1);
  $self->login($self->login || undef);
  $self->password($self->password || undef);

  return $self;
}

=head2 connect

 Connect to CommuniGate.

=cut 

sub connect {
    my $self = shift;

    my $cg_cli = new CGP::CLI({
	PeerAddr => $self->PeerAddr,
	PeerPort => $self->PeerPort,
	SecureLogin => $self->SecureLogin,
	login => $self->login,
	password => $self->password
    });

    $self->{cg_cli} = $cg_cli;

    return $self->{cg_cli};
}

=head2 get_enabled_services

 Returns hash with enabled services for
 account/domain. Accepts raw_services (AccessModes) as argument.

=cut

sub get_enabled_services {
    my $self = shift;
    my $raw_services = shift;

    # $raw_services eq 'All'
    my $enabled_services = {
	"Default" => 1,
	'Mail' => 1, 'Relay' => 1, 'Signal' =>1, 'Mobile' => 1,
	'TLS' => 1, 'POP' => 1, 'IMAP' => 1, 'MAPI' => 1,
	'AirSync' => 1, 'SIP' => 1, 'WebMail' => 1, 'XIMSS' => 1,
	'FTP' => 1, 'ACAP' => 1, 'PWD' => 1, 'LDAP' => 1,
	'RADIUS' => 1, 'S/MIME' => 1, 'WebCAL' => 1, 'WebSite' => 1,
	'PBX' => 1, 'HTTP' => 1, 'MobilePBX' => 1, 'XMedia' => 1,
	'YMedia' => 1, 'MobilePronto' => 1, 'XMPP' => 1
    };

    if (ref $raw_services eq 'ARRAY') {
	my $array_size = scalar(@{$raw_services})-1;
	my $obj_enabled_services = {};

	for my $es (1..$array_size) {
	    $obj_enabled_services->{@{$raw_services}[$es]} = 1;
	}

	for my $es (keys $enabled_services) {
	    if (!$obj_enabled_services->{$es}) {
		$enabled_services->{$es} = 0;
	    }
	}
    } elsif ($raw_services eq 'None') {
	# Remove the default setting. It is not possible to decide
	# what value it has.
	delete $enabled_services->{Default};
	for my $es (keys $enabled_services) {
	    $enabled_services->{$es} = 0;
	}
    }

    return $enabled_services;
}


=head2 logout

 Disconnect from CommuniGate.

=cut

sub logout {
    my $self = shift;

    if ($self->{cg_cli}) {
	$self->{cg_cli}->Logout();
    }
}

sub DESTROY {
    my $self  = shift;

    $self->logout();
}

=head1 AUTHOR

Ivaylo Valkov <ivaylo@e-valkov.org>

=head1 LICENSE

Awaiting approval by contractor.

=cut


1;
