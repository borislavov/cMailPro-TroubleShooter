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


sub extract_blacklisted_ips :Private {
    my ( $self, $c ) = @_;

    my $cg_cli = new $c->model("CommuniGate::CLI")->connect();

    if (!$cg_cli) {
	my $cg_err_args = [ { "cg_connection_error" => 1,
			      "cg_cli" => $cg_cli
			    }];

	$c->detach( "Root", "end", $cg_err_args );
    }

    my @blacklisted_ips = split ( /\\e/, $cg_cli->GetBlacklistedIPs());

    if (!$cg_cli->isSuccess) {
	my $args = [ { "cg_command_error" => 1,
		       "cg_cli" => $cg_cli
		     }];

	$c->detach( "Root", "end", $args );
    }

    $c->stash->{num_blacklisted_ips} = scalar(@blacklisted_ips);
}

sub extract_whitehole_ips :Private {
    my ( $self, $c ) = @_;

    my $cg_cli = new $c->model("CommuniGate::CLI")->connect();

    if (!$cg_cli) {
	my $cg_err_args = [ { "cg_connection_error" => 1,
			      "cg_cli" => $cg_cli
			    }];

	$c->detach( "Root", "end", $cg_err_args );
    }

    my @whitehole_ips = split ( /\\e/, $cg_cli->GetWhiteHoleIPs());

    if (!$cg_cli->isSuccess) {
	my $args = [ { "cg_command_error" => 1,
		       "cg_cli" => $cg_cli
		     }];

	$c->detach( "Root", "end", $args );
    }

    $c->stash->{num_whitehole_ips} = scalar(@whitehole_ips);
}

sub extract_denied_ips :Private {
    my ( $self, $c ) = @_;

    my $cg_cli = new $c->model("CommuniGate::CLI")->connect();

    if (!$cg_cli) {
	my $cg_err_args = [ { "cg_connection_error" => 1,
			      "cg_cli" => $cg_cli
			    }];

	$c->detach( "Root", "end", $cg_err_args );
    }

    my @denied_ips = split ( /\\e/, $cg_cli->GetDeniedIPs());

    if (!$cg_cli->isSuccess) {
	my $args = [ { "cg_command_error" => 1,
		       "cg_cli" => $cg_cli
		     }];

	$c->detach( "Root", "end", $args );
    }

    $c->stash->{num_denied_ips} = scalar(@denied_ips);
}

sub extract_lan_ips :Private {
    my ( $self, $c ) = @_;

    my $cg_cli = new $c->model("CommuniGate::CLI")->connect();

    if (!$cg_cli) {
	my $cg_err_args = [ { "cg_connection_error" => 1,
			      "cg_cli" => $cg_cli
			    }];

	$c->detach( "Root", "end", $cg_err_args );
    }

    my @lan_ips = split ( /\\e/, $cg_cli->GetLANIPs());

    if (!$cg_cli->isSuccess) {
	my $args = [ { "cg_command_error" => 1,
		       "cg_cli" => $cg_cli
		     }];

	$c->detach( "Root", "end", $args );
    }

    $c->stash->{num_lan_ips} = scalar(@lan_ips);
}

sub extract_client_ips :Private {
    my ( $self, $c ) = @_;

    my $cg_cli = new $c->model("CommuniGate::CLI")->connect();

    if (!$cg_cli) {
	my $cg_err_args = [ { "cg_connection_error" => 1,
			      "cg_cli" => $cg_cli
			    }];

	$c->detach( "Root", "end", $cg_err_args );
    }

    my @client_ips = split ( /\\e/, $cg_cli->GetClientIPs());

    if (!$cg_cli->isSuccess) {
	my $args = [ { "cg_command_error" => 1,
		       "cg_cli" => $cg_cli
		     }];

	$c->detach( "Root", "end", $args );
    }

    $c->stash->{num_client_ips} = scalar(@client_ips);
}

sub extract_nated_ips :Private {
    my ( $self, $c ) = @_;

    my $cg_cli = new $c->model("CommuniGate::CLI")->connect();

    if (!$cg_cli) {
	my $cg_err_args = [ { "cg_connection_error" => 1,
			      "cg_cli" => $cg_cli
			    }];

	$c->detach( "Root", "end", $cg_err_args );
    }

    my @nated_ips = split ( /\\e/, $cg_cli->GetNATedIPs());

    if (!$cg_cli->isSuccess) {
	my $args = [ { "cg_command_error" => 1,
		       "cg_cli" => $cg_cli
		     }];

	$c->detach( "Root", "end", $args );
    }

    $c->stash->{num_nated_ips} = scalar(@nated_ips);
}

sub extract_debug_ips :Private {
    my ( $self, $c ) = @_;

    my $cg_cli = new $c->model("CommuniGate::CLI")->connect();

    if (!$cg_cli) {
	my $cg_err_args = [ { "cg_connection_error" => 1,
			      "cg_cli" => $cg_cli
			    }];

	$c->detach( "Root", "end", $cg_err_args );
    }

    my @debug_ips = split ( /\\e/, $cg_cli->GetDebugIPs());

    if (!$cg_cli->isSuccess) {
	my $args = [ { "cg_command_error" => 1,
		       "cg_cli" => $cg_cli
		     }];

	$c->detach( "Root", "end", $args );
    }

    $c->stash->{num_debug_ips} = scalar(@debug_ips);

}

sub extract_tmp_blacklisted_ips :Private {
    my ( $self, $c ) = @_;

    my $cg_cli = new $c->model("CommuniGate::CLI")->connect();

    if (!$cg_cli) {
	my $cg_err_args = [ { "cg_connection_error" => 1,
			      "cg_cli" => $cg_cli
			    }];

	$c->detach( "Root", "end", $cg_err_args );
    }

    my @tmp_blacklisted_ips = split ( /\\e/, $cg_cli->GetTempBlacklistedIPs());

    if (!$cg_cli->isSuccess) {
	my $args = [ { "cg_command_error" => 1,
		       "cg_cli" => $cg_cli
		     }];

	$c->detach( "Root", "end", $args );
    }

    $c->stash->{num_tmp_blacklisted_ips} = scalar(@tmp_blacklisted_ips);

}

sub extract_tmp_client_ips :Private {
    my ( $self, $c ) = @_;

    my $cg_cli = new $c->model("CommuniGate::CLI")->connect();

    if (!$cg_cli) {
	my $cg_err_args = [ { "cg_connection_error" => 1,
			      "cg_cli" => $cg_cli
			    }];

	$c->detach( "Root", "end", $cg_err_args );
    }

    my @tmp_client_ips = split ( /\\e/, $cg_cli->GetTempClientIPs());

    if (!$cg_cli->isSuccess) {
	my $args = [ { "cg_command_error" => 1,
		       "cg_cli" => $cg_cli
		     }];

	$c->detach( "Root", "end", $args );
    }

    $c->stash->{num_tmp_client_ips} = scalar(@tmp_client_ips);

}

sub extract_domains_and_accounts :Private {
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
	my $args = [ { "cg_command_error" => 1,
		       "cg_cli" => $cg_cli
		     }];

	$c->detach( "Root", "end", $args );
    }

    my $accounts = [];

    for my $domain (@$domains) {

	my $domain_acc = $cg_cli->ListAccounts($domain);

	if (!$cg_cli->isSuccess) {

	    my $cg_err_args = [ { "cg_command_error" => 1,
				  "cg_cli" => $cg_cli
				}];

	    $c->detach( "Root", "end", $cg_err_args );
	}

	push $accounts, $domain_acc;
    }

    $c->stash->{num_domains} = scalar(@$domains);
    $c->stash->{num_accounts} = scalar(@$accounts);
}

=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->forward( 'extract_domains_and_accounts' );
    $c->forward( 'extract_blacklisted_ips' );
    $c->forward( 'extract_whitehole_ips' );
    $c->forward( 'extract_denied_ips' );
    $c->forward( 'extract_lan_ips' );
    $c->forward( 'extract_client_ips' );
    $c->forward( 'extract_nated_ips' );
    $c->forward( 'extract_debug_ips' );
    $c->forward( 'extract_tmp_blacklisted_ips' );
    $c->forward( 'extract_tmp_client_ips' );
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
