package cMailPro::TroubleShooter::Model::CommuniGate::cMailProTSAPI;
use strict;
use warnings;

use Class::C3::Adopt::NEXT;
use JSON;
use LWP::UserAgent;

use base qw(Catalyst::Model Class::Accessor);

__PACKAGE__->mk_accessors(qw|username password url verify_ssl|);

our $VERSION='0.1';



=head1 NAME

cMailPro::TroubleShooter::Model::CommuniGate::cMailProTSAPI - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 new

=cut

sub new {
  my $self = shift;
  
  $self = $self->next::method(@_);
  $self->url($self->url || undef);
  $self->username($self->username || undef);
  $self->password($self->password || undef);
  $self->verify_ssl($self->verify_ssl || 1);

  return $self;
}


=head1 fetch 

    Fetch data from CG helper CGI scripts 

=cut

sub fetch {
    my $self = shift;
    my $api_method = shift;
    my $json = {};

    my $ua = new LWP::UserAgent;
    $ua->timeout(20);
    $ua->ssl_opts(verify_hostname => $self->verify_ssl);

    my $res = $ua->post( $self->url, [ username => $self->username,
				       password => $self->password,
				       api_method => $api_method ]);

    if ($res && $res->is_success) {
	$json = decode_json $res->content;
	if ($json->{response}) {
	    $json = decode_json $json->{response};
	} else {
	    $json = { error => "cMailProTSAPI Model: No response received from CGI API script." };
	}
    } else {
	$json = { error => "cMailProTSAPI Model: Unable to communicate with CGI API script." };
    }

    return $json;
}

=head1 AUTHOR

Ivaylo Valkov <ivaylo@e-valkov.org>

=head1 LICENSE

Awaiting approval by contractor.

=cut


1;
