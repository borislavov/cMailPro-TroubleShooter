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

sub domain :LocalRegex("^(?!(~.*$))(.*)") {
    my ( $self, $c ) = @_;
    my $domain = $c->request->captures->[1];

    if (!$domain) {
	$c->response->redirect( $c->uri_for("/domains"), 302 );
    }

    $c->stash->{domain} = $domain;

    my $cg_cli = new $c->model("CommuniGate::CLI")->connect();

    if (!$cg_cli) {
	my $cg_err_args = [ { "cg_connection_error" => 1,
			      "cg_cli" => $cg_cli
			    }];

	$c->detach( "Root", "end", $cg_err_args );
    }

    my $account_list = $cg_cli->ListAccounts($domain);

    if (!$cg_cli->isSuccess) {
	my $cg_err_args = [ { "cg_command_error" => 1,
			      "cg_cli" => $cg_cli
			    }];

	$c->detach( "Root", "end", $cg_err_args );
    }

    $c->stash->{account_list} = $account_list;

    my $domain_settings = $cg_cli->GetDomainEffectiveSettings($domain);

    if (!$cg_cli->isSuccess) {
	my $cg_err_args = [ { "cg_command_error" => 1,
			      "cg_cli" => $cg_cli
			    }];

	$c->detach( "Root", "end", $cg_err_args );
    }

    # Prepare Enabled Services

    my $enabled_services =
	$c->model("CommuniGate::CLI")->get_enabled_services($domain_settings->{DomainAccessModes});

    $c->stash->{enabled_services} = $enabled_services;

    for my $k (keys $domain_settings) {
	if (ref $domain_settings->{$k} eq 'ARRAY') {
	    $domain_settings->{$k} = join (", ",@{$domain_settings->{$k}});
	}
    }

    $c->stash->{domain_settings} = $domain_settings;

    my $account_defaults = $cg_cli->GetAccountDefaults($domain);

    if (!$cg_cli->isSuccess) {
	my $cg_err_args = [ { "cg_command_error" => 1,
			      "cg_cli" => $cg_cli
			    }];

	$c->detach( "Root", "end", $cg_err_args );
    }

    $account_defaults =
	$c->model("CommuniGate::CLI")->get_enabled_services($account_defaults->{AccessModes});

    $c->stash->{account_defaults} = $account_defaults;

}

=head2 search

=cut 

sub search :LocalRegex('^~search(/)*(.*)') {
    my ( $self, $c ) = @_;

    my $domain = $c->request->captures->[1];

    if ($c->request->method eq "POST") {
	$domain = $c->request->param("domain");
    }

    if ($domain && $c->request->path !~ /$domain$/ ) {
	$c->response->redirect( $c->uri_for("~search/$domain"), 302 );
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
