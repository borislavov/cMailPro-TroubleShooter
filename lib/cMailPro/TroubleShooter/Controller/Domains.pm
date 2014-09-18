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

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    my $cg_cli = new $c->model("CommuniGate::CLI")->connect();

    if (!$cg_cli) {
	my $cg_err_args = [ { "cg_connection_error" => 1,
			      "cg_cli" => $cg_cli
			    }];

	$c->detach( "Root", "end", $cg_err_args );
    }

    my $domains = $cg_cli->ListDomains();

    if (!$cg_cli->isSuccess) {
	my $cg_err_args = [ { "cg_command_error" => 1,
			      "cg_cli" => $cg_cli
			    }];

	$c->detach( "Root", "end", $cg_err_args );
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
	my $cg_err_args = [ { "cg_connection_error" => 1,
			      "cg_cli" => $cg_cli
			    }];

	$c->detach( "Root", "end", $cg_err_args );
    }

    my $domain_settings = $cg_cli->GetDomainEffectiveSettings($domain);

    for my $k (keys $domain_settings) {
	if (ref $domain_settings->{$k} eq 'ARRAY') {
	    $domain_settings->{$k} = join (", ",@{$domain_settings->{$k}});
	}
    }

    $c->log->debug(Dumper $domain_settings);

    if (!$cg_cli->isSuccess) {
	my $cg_err_args = [ { "cg_command_error" => 1,
			      "cg_cli" => $cg_cli
			    }];

	$c->detach( "Root", "end", $cg_err_args );
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
	my $cg_err_args = [ { "cg_connection_error" => 1,
			      "cg_cli" => $cg_cli
			    }];

	$c->detach( "Root", "end", $cg_err_args );
    }

    my $domains = $cg_cli->ListDomains();

    if (!$cg_cli->isSuccess) {

	my $cg_err_args = [ { "cg_command_error" => 1,
			      "cg_cli" => $cg_cli
			    }];

	$c->detach( "Root", "end", $cg_err_args );
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
