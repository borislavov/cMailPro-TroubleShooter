package cMailPro::TroubleShooter::Controller::Accounts;
use Moose;
use namespace::autoclean;

use Data::Dumper;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

cMailPro::TroubleShooter::Controller::Accounts - Catalyst Controller

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

    my $render_accounts  = [];

    for my $domain (@$domains) {
	my $accounts = $cg_cli->ListAccounts($domain);

	if (!$cg_cli->isSuccess) {
	    my $cg_err_args = [ { "cg_command_error" => 1,
				  "cg_cli" => $cg_cli
				}];

	    $c->detach( "Root", "end", $cg_err_args );
	}

	foreach my $account (keys $accounts) {
	    push $render_accounts, { "domain" => $domain,
				     "account" => $account
	    };
	}
    }

    $c->stash->{accounts} = $render_accounts;
}

=head2 account

  Match single account and extract data for it.

=cut 

sub account :LocalRegex("^(?!(search(/)|search/.*|search$))(.*)/(.*)") {
    my ( $self, $c ) = @_;
    my $account = $c->request->captures->[3];
    my $domain = $c->request->captures->[2];

    if (!$account) {
	$c->response->redirect( $c->uri_for("/accounts"), 302 );
    }

    my $cg_cli = new $c->model("CommuniGate::CLI")->connect();

    if (!$cg_cli) {
	my $cg_err_args = [ { "cg_connection_error" => 1,
			      "cg_cli" => $cg_cli
			    }];

	$c->detach( "Root", "end", $cg_err_args );
    }

    my $account_settings = $cg_cli->GetAccountEffectiveSettings("$account\@$domain");

    if (!$cg_cli->isSuccess) {
	my $cg_err_args = [ { "cg_command_error" => 1,
			      "cg_cli" => $cg_cli
			    }];

	$c->detach( "Root", "end", $cg_err_args );
    }

    # Hide plain passowrds.
    if ($account_settings->{Password}) {
	$account_settings->{Password} = "*******";
    }

    $c->stash->{account_settings} = $account_settings;
    $c->stash->{account} = $account;
    $c->stash->{domain} = $domain;
}

=head2 search

    Search for an account.

=cut 

sub search :LocalRegex('^search(/)*(.*)') {
    my ( $self, $c ) = @_;

    my $account = $c->request->captures->[1];

    if ($c->request->method eq "POST") {
	$account = $c->request->param("account");
    }

    if ($account && $c->request->path !~ /$account$/ ) {
	$c->response->redirect( $c->uri_for("search/$account"), 302 );
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

    my $found = [];

    my ($acc_user, $acc_domain);

    if ( $account =~ m/@/) {
	($acc_user, $acc_domain) = split("@", $account);
    }

    $c->stash->{account_searched} = $account;

    $account = quotemeta($account);

    if ($acc_user) {
	$acc_user = quotemeta($acc_user);
    }

    if ($acc_domain) {
	$acc_domain = quotemeta ($acc_domain);
    }

    for my $domain (@$domains) {

	my $accounts = $cg_cli->ListAccounts($domain);

	if (!$cg_cli->isSuccess) {

	    my $cg_err_args = [ { "cg_command_error" => 1,
				  "cg_cli" => $cg_cli
				}];

	    $c->detach( "Root", "end", $cg_err_args );
	}

	foreach my $acc (keys $accounts) {

	    if ( !$account ) {
		push $found, { domain => $domain, account => $acc };
		next;
	    }

	    if ( !$acc_domain && !$acc_user ) {
		if ( $domain =~ m/$account/ || $acc =~ m/$account/ ) {

		    push $found, { domain => $domain,
				   account => $acc
		    };
		}
	    } elsif ($acc_domain || $acc_user ) {
		if ( $domain =~ m/$acc_domain/ || 
		     $acc =~ m/$acc_user/ )  {

		    push $found, { domain => $domain,
				   account => $acc
		    };
		}
	    }
	}
    }

    $c->stash->{accounts} = $found;
}


=head1 AUTHOR

Ivaylo Valkov <ivaylo@e-valkov.org>

=head1 LICENSE

Awaiting contractor approval.

=cut

__PACKAGE__->meta->make_immutable;

1;
