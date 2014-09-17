package cMailPro::TroubleShooter::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=head1 NAME

cMailPro::TroubleShooter::Controller::Root - Root Controller for cMailPro::TroubleShooter

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 begin

=cut

sub begin :Private {
    my ( $self, $c ) = @_;
}

=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {
    my ( $self, $c, $args ) = @_;

    if ( (ref ($args) eq 'HASH')
	 && $args->{cg_command_error} ) {

	$c->response->status(500);
	$c->stash->{error_msg} = [ $args->{cg_cli}->getErrMessage ];
	$c->stash->{status_msg} = ["Internal Server Error. Unable to execute CommuniGate commad: ". $args->{cg_cli}->getErrCommand ];

	$c->log->debug("CommuniGate command error: ", $args->{cg_cli}->getErrMessage);
    }

    if ( (ref ($args) eq 'HASH')
	 && $args->{cg_connection_error} ) {

	$c->response->status(500);
	$c->stash->{error_msg} = [ "Unable to create CommuniGate connection channel." ];
	$c->stash->{status_msg} = [ "Internal Server Error. Unable to connect to the CommuniGate server." ];

	$c->log->debug("CommuniGate connection error. ");
    }

    $c->model("CommuniGate::CLI")->logout();
}

=head1 AUTHOR

Ivaylo Valkov <ivaylo@e-valkov.org>

=head1 LICENSE

Awaiting approval by contractor.

=cut

__PACKAGE__->meta->make_immutable;

1;
