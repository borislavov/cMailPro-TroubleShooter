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
	    my $acc_type =
		$c->model("CommuniGate::CLI")->get_account_type($accounts->{$account});

	    push $render_accounts, { "domain" => $domain,
				     "account" => $account,
				     "type"  => $acc_type
	    };
	}
    }

    $c->stash->{accounts} = $render_accounts;
}

=head2 account

  Match single account and extract data for it.

=cut 

sub account :LocalRegex("^(?!(~.*$))(.*)/(.*)") {
    my ( $self, $c ) = @_;
    my $account = $c->request->captures->[2];
    my $domain = $c->request->captures->[1];

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


    my $account_type = $cg_cli->GetAccountLocation("$account\@$domain");

    if (!$cg_cli->isSuccess) {
	my $cg_err_args = [ { "cg_command_error" => 1,
			      "cg_cli" => $cg_cli
			    }];

	$c->detach( "Root", "end", $cg_err_args );
    }

    $account_type =~ s/$account\.//;
    $account_type = $c->model("CommuniGate::CLI")->get_account_type($account_type);

    $c->stash->{acc_type} = $account_type;

    my $account_info = $cg_cli->GetAccountInfo("$account\@$domain");

    if (!$cg_cli->isSuccess) {
	my $cg_err_args = [ { "cg_command_error" => 1,
			      "cg_cli" => $cg_cli
			    }];

	$c->detach( "Root", "end", $cg_err_args );
    }

    # Clear some characters from dates and IP addreses strings
    my @clear_strings = ( "Created", "LastLogin", "PrevLogin",
		 "LastFailedLogin", "LastAddress", "PrevLoginAddress",
		 "LastFailedLoginAddress");

    for my $cs (@clear_strings) {
	$account_info->{$cs} =~  s/_/ / unless !$account_info->{$cs};
	$account_info->{$cs} =~  s/\[// unless !$account_info->{$cs};
	$account_info->{$cs} =~  s/\]// unless !$account_info->{$cs};
	$account_info->{$cs} =~  s/#T// unless !$account_info->{$cs};
    }

    $c->stash->{account_info} = $account_info;

    my $account_settings = $cg_cli->GetAccountEffectiveSettings("$account\@$domain");

    if (!$cg_cli->isSuccess) {
	my $cg_err_args = [ { "cg_command_error" => 1,
			      "cg_cli" => $cg_cli
			    }];

	$c->detach( "Root", "end", $cg_err_args );
    }

    # Prepare Enabled Services

    my $enabled_services =
	$c->model("CommuniGate::CLI")->get_enabled_services($account_settings->{AccessModes});

    $c->stash->{enabled_services} = $enabled_services;


    # Prepare RPOP data

    my $mail_rpop = $account_settings->{RPOP};

    if ($mail_rpop) {
	for my $m (keys $mail_rpop) {
	    $mail_rpop->{$m}->{password} = "*****";
	    $mail_rpop->{$m}->{leave} = $mail_rpop->{$m}->{APOP} ? 1: 0;
	    $mail_rpop->{$m}->{TLS} = $mail_rpop->{$m}->{APOP} ? 1: 0;
	    $mail_rpop->{$m}->{APOP} = $mail_rpop->{$m}->{APOP} ? 1 : 0;
	}
    }

    $c->stash->{mail_rpop} = $account_settings->{RPOP};
    $c->stash->{mail_rpop_mod} = ($account_settings->{RPOPAllowed} eq 'YES') ? 1 : 0;


    # Prepare RSIP data

    my $realtime_rsip = $account_settings->{RSIP};

    if ($realtime_rsip) {
	for my $m (keys $realtime_rsip) {
	    $realtime_rsip->{$m}->{password} = "*****";
	}
    }

    $c->stash->{realtime_rsip} = $account_settings->{RSIP};
    $c->stash->{realtime_rsip_mod} = ($account_settings->{RSIPAllowed} eq 'YES') ? 1 : 0;


    for my $k (keys $account_settings) {
	if (ref $account_settings->{$k} eq 'ARRAY') {
	    $account_settings->{$k} = join (", ",@{$account_settings->{$k}});
	}
    }

    # Hide plain passowrds.
    if ($account_settings->{Password}) {
	$account_settings->{Password} = "*******";
    }

    $c->stash->{account_settings} = $account_settings;
    $c->stash->{account} = $account;
    $c->stash->{domain} = $domain;
}

sub verify_password :LocalRegex("^~verify_password((/)*(.*)/(.*))*") {
    my ( $self, $c ) = @_;

    my $account = $c->request->captures->[3].'@'.$c->request->captures->[2];
    $account = ($account eq '@') ? '' : $account;

    my $password;

    if ($c->request->method eq "POST") {
	$account = $c->request->param("account") unless $account;
	$password = $c->request->param("password");
    }

    $c->stash->{account} = $account;
    $c->stash->{password} = $password;

    # Just render the form
    if (!$account) {
	$c->detach( "Root", "end");
    }

    my $cg_cli = new $c->model("CommuniGate::CLI")->connect();

    if (!$cg_cli) {
	my $cg_err_args = [ { "cg_connection_error" => 1,
			      "cg_cli" => $cg_cli
			    }];

	$c->detach( "Root", "end", $cg_err_args );
    }

    if ($account && $password) {
	my $verify_account = $cg_cli->VerifyAccountPassword("$account", $password);

	if (!$cg_cli->isSuccess) {

	    # Error code 515 is for invalid user or password
	    # Error code 512 is for invalid domain
	    if ($cg_cli->getErrCode != 515 &&
		$cg_cli->getErrCode != 512) {
		my $cg_err_args = [ { "cg_command_error" => 1,
				      "cg_cli" => $cg_cli
				    }];

		$c->detach( "Root", "end", $cg_err_args );
	    } else {
		$c->stash->{error_msg} = [ "Invalid user or password" ] ;
	    }
	}

	$c->stash->{verify_account_password} = $verify_account ? "Valid" : "Invalid";
    }
}


sub change_password :LocalRegex("^~change_password((/)*(.*)/(.*))*") {
    my ( $self, $c ) = @_;

    my $account = $c->request->captures->[3].'@'.$c->request->captures->[2];
    $account = ($account eq '@') ? '' : $account;

    my ( $password, $confirm_password );

    if ($c->request->method eq "POST") {
	$account = $c->request->param("account") unless $account;
	$password = $c->request->param("password");
	$confirm_password = $c->request->param("password-confirm");
    }

    $c->stash->{account} = $account;

    # Just render the form
    if (!$account) {
	$c->detach( "Root", "end");
    }

    # Render with error
    if ($c->request->method eq "POST"  &&
	( $password ne $confirm_password) ) {
	$c->stash->{error_msg} = [ "Passwords do not match" ] ;
	$c->stash->{change_account_password} = "Passwords do not match";
	$c->detach( "Root", "end");
    }

    my $cg_cli = new $c->model("CommuniGate::CLI")->connect();

    if (!$cg_cli) {
	my $cg_err_args = [ { "cg_connection_error" => 1,
			      "cg_cli" => $cg_cli
			    }];

	$c->detach( "Root", "end", $cg_err_args );
    }

    if ($account && $password) {
	my $change_account = $cg_cli->UpdateAccountSettings("$account", { Password => $password });

	if (!$cg_cli->isSuccess) {

	    # Error code 513 is for invalid user
	    # Error code 512 is for invalid domain
	    if ($cg_cli->getErrCode != 513 &&
		$cg_cli->getErrCode != 512) {
		my $cg_err_args = [ { "cg_command_error" => 1,
				      "cg_cli" => $cg_cli
				    }];

		$c->detach( "Root", "end", $cg_err_args );
	    } else {
		$c->stash->{error_msg} = [ "Invalid account" ] ;
	    }
	}

	$c->stash->{change_account_password} = $change_account ? "Password changed" : "Password not changed";
    }
}

=head2 search

    Search for an account.

=cut 

sub search :LocalRegex('^~search(/)*(.*)') {
    my ( $self, $c ) = @_;

    my $account = $c->request->captures->[1];

    if ($c->request->method eq "POST") {
	$account = $c->request->param("account");
    }

    if ($account && $c->request->path !~ /$account$/ ) {
	$c->response->redirect( $c->uri_for("~search/$account"), 302 );
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
	    my $acc_type =
		$c->model("CommuniGate::CLI")->get_account_type($accounts->{$acc});

	    if ( !$account ) {
		push $found, { domain => $domain,
			       account => $acc,
			       type => $acc_type };
		next;
	    }

	    if ( !$acc_domain && !$acc_user ) {
		if ( $domain =~ m/$account/ || $acc =~ m/$account/ ) {

		    push $found, { domain => $domain,
				   account => $acc,
				   type =>  $acc_type
		    };
		}
	    } elsif ($acc_domain || $acc_user ) {
		if ( $domain =~ m/$acc_domain/ || 
		     $acc =~ m/$acc_user/ )  {
		    push $found, { domain => $domain,
				   account => $acc,
				   type => $acc_type
		    };
		}
	    }
	}
    }

    $c->stash->{accounts} = $found;
}


=head2 edit

 Edit account information

=cut

sub edit :LocalRegex('^~edit(/)*(.*)/(.*)') {
    my ( $self, $c ) = @_;

    my $account = $c->request->captures->[2];
    my $domain = $c->request->captures->[1];

    if ( $c->request->method eq 'POST') {
	my $acc_settings = {};
	my $param_settings = {
	    real_name => 'RealName',
	    state => 'st',
	    city => 'l',
	    unit => 'ou',
	    password => 'Password',
	    account_services => 'AccessModes'
	};

	foreach my $k (keys $param_settings) {
	    if ($k eq 'account_services' && $c->request->param($k) ) {

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
		    push @{$acc_settings->{$param_settings->{$k}}}, 27;
		    push @{$acc_settings->{$param_settings->{$k}}}, $c->request->param('account_services');
		} else {
		    $acc_settings->{$param_settings->{$k}} = $all_none_default;
		}
	    } elsif ( $k eq 'password' && $c->request->param('password') &&
		 $c->request->param('confirm-password') &&
		 ($c->request->param('password-confirm') eq $c->request->param('password') ) ) {
		$acc_settings->{$param_settings->{$k}} = $c->request->param($k);
	    } elsif ($c->request->param($k) ) {
		$acc_settings->{$param_settings->{$k}} = $c->request->param($k);
	    }
	}

	my $cg_cli = new $c->model("CommuniGate::CLI")->connect();

	if (!$cg_cli) {
	    my $cg_err_args = [ { "cg_connection_error" => 1,
				  "cg_cli" => $cg_cli
				}];

	    $c->detach( "Root", "end", $cg_err_args );
	}

	$cg_cli->UpdateAccountSettings($account.'@'.$domain, $acc_settings);

	if (!$cg_cli->isSuccess) {

	    my $cg_err_args = [ { "cg_command_error" => 1,
				  "cg_cli" => $cg_cli
				}];

	    $c->detach( "Root", "end", $cg_err_args );
	}
    }

    $c->forward( 'Accounts', 'account', $c->request->args );

    $c->stash->{account_types} =
	$c->model("CommuniGate::CLI")->account_types();
}

=head1 AUTHOR

Ivaylo Valkov <ivaylo@e-valkov.org>

=head1 LICENSE

Awaiting contractor approval.

=cut

__PACKAGE__->meta->make_immutable;

1;
