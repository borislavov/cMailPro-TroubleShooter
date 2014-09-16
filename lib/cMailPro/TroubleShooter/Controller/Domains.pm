package cMailPro::TroubleShooter::Controller::Domains;
use Moose;
use namespace::autoclean;
use Data::Dumper;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

cMailPro::TroubleShooter::Controller::Domains - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 init_cg_cli 

=cut

sub cg_connection_error :Private {
    my ( $self, $c ) = @_;

    $c->response->status(500);
    $c->stash->{error_msg} = "Unable to create CommuniGate connection";
    $c->stash->{status_msg} = "Internal Server Error: Unable to execute CommuniGate commad ListDomains";
    $c->log->debug("CommuniGate connection error. ");
    $c->detach( $c->view('HTML'));
}

=head2 cg_command_error 

=cut

sub cg_command_error :Private {
    my ( $self, $c, $cg_cli ) = @_;

    $c->response->status(500);
    $c->stash->{error_msg} = $cg_cli->getErrMessage;
    $c->stash->{status_msg} = "Internal Server Error: Unable to execute CommuniGate commad ", $cg_cli->getErrCommand;
    $c->log->debug("CommuniGate connection error: ", $cg_cli->getErrMessage);
    $c->detach( $c->view('HTML'));
}

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    my $cg_cli = new $c->model("CommuniGate::CLI")->connect();

    if (!$cg_cli) {
	$self->cg_connection_error;
    }

    my $domains = $cg_cli->ListDomains();

    if (!$cg_cli->isSuccess) {
	$self->cg_command_error($cg_cli);
    }

    $c->stash->{domains} = $domains;
}

=head2 domain

  Match single domain and extract data for it.

=cut 

sub domain :LocalRegex("^(?!(search(/)|search/.*|search$))(.*)") {
    my ( $self, $c ) = @_;
    my $domain = $c->request->captures->[2];

    if (!$domain) {
	$c->response->redirect( $c->uri_for("/domains"), 302 );
    }

    my $cg_cli = new $c->model("CommuniGate::CLI")->connect();

    if (!$cg_cli) {
	$self->cg_connection_error;
    }

    my $domain_settings= $cg_cli->GetDomainSettings($domain);

    $c->log->debug(Dumper $domain_settings);

    if (!$cg_cli->isSuccess) {
	$self->cg_command_error($cg_cli);
    }

    $c->stash->{domain_settings} = $domain_settings;
    $c->stash->{domain} = $domain;
}

=head2 search

=cut 

sub search :LocalRegex('^search(/)*(.*)') {
    my ( $self, $c ) = @_;

    my $domain = $c->request->captures->[1];

    if ($c->request->method eq "POST") {
	$domain = $c->request->param("domain");
    }

    if ($domain && $c->request->path !~ /$domain$/ ) {
	$c->response->redirect( $c->uri_for("search/$domain"), 302 );
    }

    my $cg_cli = new $c->model("CommuniGate::CLI")->connect();

    if (!$cg_cli) {
	$self->cg_connection_error;
    }

    my $domains = $cg_cli->ListDomains();

    if (!$cg_cli->isSuccess) {
	$self->cg_command_error($cg_cli);
    }

    if (!$domain) {
	$c->stash->{domains} = $domains;
	$c->detach( $c->view('HTML'));
    }

    my @found;

    $c->stash->{domain_searched} = $domain;

    $domain = quotemeta($domain);

    for my $d (@$domains) {

	if ( $d =~ m/$domain/ ){
	    push @found,$d;
	}
    }

    $c->stash->{domains} = \@found;
}


=head1 AUTHOR

Ivaylo Valkov <ivaylo@e-valkov.org>

=head1 LICENSE

Awayting approval by contractor.

=cut

__PACKAGE__->meta->make_immutable;

1;
