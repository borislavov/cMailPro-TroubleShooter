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

    # Mail groups
    my $group_list = $cg_cli->ListGroups($domain);

    if (!$cg_cli->isSuccess) {
	my $cg_err_args = [ { "cg_command_error" => 1,
			      "cg_cli" => $cg_cli
			    }];

	$c->detach( "Root", "end", $cg_err_args );
    }

    foreach my $g (@{$group_list}) {

	my $group_settings  = $cg_cli->GetGroup("$g\@$domain");

	if (!$cg_cli->isSuccess) {
	    my $cg_err_args = [ { "cg_command_error" => 1,
				  "cg_cli" => $cg_cli
				}];

	    $c->detach( "Root", "end", $cg_err_args );
	}
	push @{$c->stash->{mail_groups}}, { name => $g, members => sort ($group_settings->{Members}) } ;
    }

    # Forwarders
    my $forwarder_list = $cg_cli->ListForwarders($domain);

    if (!$cg_cli->isSuccess) {
	my $cg_err_args = [ { "cg_command_error" => 1,
			      "cg_cli" => $cg_cli
			    }];

	$c->detach( "Root", "end", $cg_err_args );
    }

    foreach my $f (@{$forwarder_list}) {

	my $forwarder  = $cg_cli->GetForwarder("$f\@$domain");

	if (!$cg_cli->isSuccess) {
	    my $cg_err_args = [ { "cg_command_error" => 1,
				  "cg_cli" => $cg_cli
				}];

	    $c->detach( "Root", "end", $cg_err_args );
	}
	push @{$c->stash->{mail_forwarders}}, { name => "$f\@$domain", to => $forwarder } ;
    }

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


=head2 edit

 Edit domain information

=cut

sub edit :LocalRegex('^~edit(/)*(.*)') {
    my ( $self, $c ) = @_;

    my $domain = $c->request->captures->[1];

    if ( $c->request->method eq 'POST') {
	my $domain_settings = {};
	my $account_defaults = {};
	my $param_settings = {
	    account_defaults_services => 'AccessModes',
	    domain_services => 'DomainAccessModes'
	};

	foreach my $k (keys $param_settings) {
	    if ($k eq 'domain_services' && $c->request->param($k) ) {

		my $all_none_default = 0;
		my @services = $c->request->param($k);
		my $array_size = scalar(@services)-1;

		for my $s (0..$array_size) {
		    my $srv = $services[$s];
		    if ($srv eq 'Default' || $srv eq 'All' || $srv eq 'None') {
			$all_none_default = $srv unless $all_none_default;
			delete $services[$s];
		    }
		}

		if ( !$all_none_default) {
		    # 27: MobilePronto ; Larger tan 27 are enabled. 27
		    # is always returned by CG. Hackish!
		    push @{$domain_settings->{$param_settings->{$k}}}, 27;
		    push @{$domain_settings->{$param_settings->{$k}}}, $c->request->param('domain_services');
		} else {
		    $domain_settings->{$param_settings->{$k}} = $all_none_default;
		}
	    } elsif ($k eq 'account_defaults_services' && $c->request->param($k)) {
		my $ad_all_none_default = 0;
		my @ad_services = $c->request->param($k);
		my $ad_array_size = scalar(@ad_services)-1;

		for my $ad_s (0..$ad_array_size) {
		    my $ad_srv = $ad_services[$ad_s];
		    if ($ad_srv eq 'Default' || $ad_srv eq 'All' || $ad_srv eq 'None') {
			$ad_all_none_default = $ad_srv unless $ad_all_none_default;
			delete $ad_services[$ad_s];
		    }
		}

		if ( !$ad_all_none_default) {
		    # 27: MobilePronto ; Larger tan 27 are enabled. 27
		    # is always returned by CG. Hackish!
		    push @{$account_defaults->{$param_settings->{$k}}}, 27;
		    push @{$account_defaults->{$param_settings->{$k}}}, $c->request->param('account_defaults_services');
		} else {
		    $account_defaults->{$param_settings->{$k}} = $ad_all_none_default;
		}
	    }
	}

	my $cg_cli = new $c->model("CommuniGate::CLI")->connect();

	if (!$cg_cli) {
	    my $cg_err_args = [ { "cg_connection_error" => 1,
				  "cg_cli" => $cg_cli
				}];

	    $c->detach( "Root", "end", $cg_err_args );
	}

	if ($c->request->param('domain_services') ) {

	    $cg_cli->UpdateDomainSettings( domain => $domain, settings => $domain_settings);

	    if (!$cg_cli->isSuccess) {

		my $cg_err_args = [ { "cg_command_error" => 1,
				      "cg_cli" => $cg_cli
				    }];

		$c->detach( "Root", "end", $cg_err_args );
	    }
	}

	if ($c->request->param('account_defaults_services') ) {
	    $cg_cli->UpdateAccountDefaults( domain => $domain, settings => $account_defaults);

	    if (!$cg_cli->isSuccess) {

		my $cg_err_args = [ { "cg_command_error" => 1,
				      "cg_cli" => $cg_cli
				    }];

		$c->detach( "Root", "end", $cg_err_args );
	    }
	}
    }

    $c->forward( 'Domains', 'domain', $c->request->args );
}


=head1 AUTHOR

Ivaylo Valkov <ivaylo@e-valkov.org>

=head1 LICENSE

Awayting approval by contractor.

=cut

__PACKAGE__->meta->make_immutable;

1;
