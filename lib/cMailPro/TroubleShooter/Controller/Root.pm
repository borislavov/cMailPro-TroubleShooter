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
    $self->{cg_cli} = $c->model("CommuniGate::CLI");
}

=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    # Hello World
    # $c->response->body( $c->welcome_message );
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
    my ( $self, $c ) = @_;

    $c->model("CommuniGate::CLI")->logout();
}

=head1 AUTHOR

Ivaylo Valkov <ivaylo@e-valkov.org>

=head1 LICENSE

Awaiting approval by contractor.

=cut

__PACKAGE__->meta->make_immutable;

1;
