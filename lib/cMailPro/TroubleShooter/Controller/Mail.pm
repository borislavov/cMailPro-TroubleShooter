package cMailPro::TroubleShooter::Controller::Mail;
use Moose;
use namespace::autoclean;
use LWP::UserAgent;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

cMailPro::TroubleShooter::Controller::Mail - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    
    $c->response->redirect( $c->uri_for('/mail/messages'), 302 );
}

=head2 messages


=cut

sub messages :LocalRegexp("^(?!(~.*$))messages$") {
    my ( $self, $c ) = @_;

    my $cg_ts_api = new $c->model('CommuniGate::cMailProTSAPI');
    my $messages = $cg_ts_api->fetch('/messages');

    $c->stash->{messages} = $messages->{messages} unless !$messages->{messages};

    if ( $messages->{error} ) {
	$c->response->status(500);
	$c->stash->{error_msg} = [ $messages->{error} ];
	$c->stash->{status_msg} = ["Internal Server Error. CGI API communication error."];
    }
}

=head2  message

=cut 

sub message :LocalRegexp("^(?!(~.*$))messages/(.*)") {
    my ( $self, $c ) = @_;

    my $message_id = $c->request->captures->[1];

    my $cg_ts_api = new $c->model('CommuniGate::cMailProTSAPI');
    my $message = $cg_ts_api->fetch('/messages/'. $message_id);

    if ($message && $message->{message}) {
        $c->stash->{message} = $message->{message} ;
    } else {
	$c->response->status(404);
	$c->stash->{error_msg} = [ "Message " . $message_id." not found" ];
    }

    if ( $message->{error} ) {
	$c->response->status(500);
	$c->stash->{error_msg} = [ $message->{error} ];
	$c->stash->{status_msg} = ["Internal Server Error. CGI API communication error."];
    }
}



=head1 AUTHOR

Ivaylo Valkov <ivaylo@e-valkov.org>

=head1 LICENSE

Awaiting approval by contractor.

=cut

__PACKAGE__->meta->make_immutable;

1;
