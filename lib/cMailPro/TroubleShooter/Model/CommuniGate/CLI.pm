package cMailPro::TroubleShooter::Model::CommuniGate::CLI;
use strict;
use warnings;

use Class::C3::Adopt::NEXT;

use CLI;
use Data::Dumper;
use Catalyst::Log;

use base qw(Catalyst::Model Class::Accessor);

__PACKAGE__->mk_accessors(qw|PeerAddr PeerPort SecureLogin login password|);

our $VERSION='0.1';

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
