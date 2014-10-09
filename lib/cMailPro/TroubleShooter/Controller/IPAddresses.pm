package cMailPro::TroubleShooter::Controller::IPAddresses;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

cMailPro::TroubleShooter::Controller::IPAddresses - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    
    $c->response->redirect( $c->uri_for('/ip_addresses'), 302 );
}

sub ip_addresses :Regex('^ip_addresses$') {
    my ( $self, $c ) = @_;

    $c->stash->{template} = 'ipaddresses/index.tt2';

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

    $c->stash->{blacklisted_ips} = \@blacklisted_ips;

    my @whitehole_ips = split ( /\\e/, $cg_cli->GetWhiteHoleIPs());

    if (!$cg_cli->isSuccess) {
	my $args = [ { "cg_command_error" => 1,
		       "cg_cli" => $cg_cli
		     }];

	$c->detach( "Root", "end", $args );
    }

    $c->stash->{whitehole_ips} = \@whitehole_ips;

    my @denied_ips = split ( /\\e/, $cg_cli->GetDeniedIPs());

    if (!$cg_cli->isSuccess) {
	my $args = [ { "cg_command_error" => 1,
		       "cg_cli" => $cg_cli
		     }];

	$c->detach( "Root", "end", $args );
    }

    $c->stash->{denied_ips} = \@denied_ips;

    my @lan_ips = split ( /\\e/, $cg_cli->GetLANIPs());

    if (!$cg_cli->isSuccess) {
	my $args = [ { "cg_command_error" => 1,
		       "cg_cli" => $cg_cli
		     }];

	$c->detach( "Root", "end", $args );
    }

    $c->stash->{lan_ips} = \@lan_ips;

    my @client_ips = split ( /\\e/, $cg_cli->GetClientIPs());

    if (!$cg_cli->isSuccess) {
	my $args = [ { "cg_command_error" => 1,
		       "cg_cli" => $cg_cli
		     }];

	$c->detach( "Root", "end", $args );
    }

    $c->stash->{client_ips} = \@client_ips;

    my @nated_ips = split ( /\\e/, $cg_cli->GetNATedIPs());

    if (!$cg_cli->isSuccess) {
	my $args = [ { "cg_command_error" => 1,
		       "cg_cli" => $cg_cli
		     }];

	$c->detach( "Root", "end", $args );
    }

    $c->stash->{nated_ips} = \@nated_ips;

    my @debug_ips = split ( /\\e/, $cg_cli->GetDebugIPs());

    if (!$cg_cli->isSuccess) {
	my $args = [ { "cg_command_error" => 1,
		       "cg_cli" => $cg_cli
		     }];

	$c->detach( "Root", "end", $args );
    }

    $c->stash->{debug_ips} = \@debug_ips;


    my @tmp_blacklisted_ips = split ( /\\e/, $cg_cli->GetTempBlacklistedIPs());

    if (!$cg_cli->isSuccess) {
	my $args = [ { "cg_command_error" => 1,
		       "cg_cli" => $cg_cli
		     }];

	$c->detach( "Root", "end", $args );
    }

    $c->stash->{tmp_blacklisted_ips} = \@tmp_blacklisted_ips;


    my @tmp_client_ips = split ( /\\e/, $cg_cli->GetTempClientIPs());

    if (!$cg_cli->isSuccess) {
	my $args = [ { "cg_command_error" => 1,
		       "cg_cli" => $cg_cli
		     }];

	$c->detach( "Root", "end", $args );
    }

    $c->stash->{tmp_client_ips} = \@tmp_client_ips;

}

=head2 edit

 Edit CG IP addressess

=cut

sub edit :Regex('^ip_addresses/~edit') {
    my ( $self, $c ) = @_ ;

    if ( $c->request->method eq 'POST' ) {
	my $cg_cli = new $c->model("CommuniGate::CLI")->connect();

	if (!$cg_cli) {
	    my $cg_err_args = [ { "cg_connection_error" => 1,
				  "cg_cli" => $cg_cli
				}];

	    $c->detach( "Root", "end", $cg_err_args );
	}

	my $blacklisted_ips = $c->request->param('blacklisted_ips');

	if ($blacklisted_ips) {
	    $blacklisted_ips =~ s/\s*;.*//g;
	    $blacklisted_ips =~ s/^\s+$//g;
	    $blacklisted_ips =~ s/\s+/ /g;
	    $blacklisted_ips =~ s/\n/ /g;
	    $blacklisted_ips =~ s/\s$//g;
	    $blacklisted_ips =~ s/ /\\e/g;

	    $cg_cli->SetBlacklistedIPs($blacklisted_ips);

	    if (!$cg_cli->isSuccess) {
		my $args = [ { "cg_command_error" => 1,
			       "cg_cli" => $cg_cli
			     }];

		$c->detach( "Root", "end", $args );
	    }
	}


	my $denied_ips = $c->request->param('denied_ips');

	if ($denied_ips) {
	    $denied_ips =~ s/\s*;.*//g;
	    $denied_ips =~ s/^\s+$//g;
	    $denied_ips =~ s/\s+/ /g;
	    $denied_ips =~ s/\n/ /g;
	    $denied_ips =~ s/\s$//g;
	    $denied_ips =~ s/ /\\e/g;

	    $cg_cli->SetDeniedIPs($denied_ips);

	    if (!$cg_cli->isSuccess) {
		my $args = [ { "cg_command_error" => 1,
			       "cg_cli" => $cg_cli
			     }];

		$c->detach( "Root", "end", $args );
	    }
	}


	my $client_ips = $c->request->param('client_ips');

	if ($client_ips) {
	    $client_ips =~ s/\s*;.*//g;
	    $client_ips =~ s/^\s+$//g;
	    $client_ips =~ s/\s+/ /g;
	    $client_ips =~ s/\n/ /g;
	    $client_ips =~ s/\s$//g;
	    $client_ips =~ s/ /\\e/g;

	    $cg_cli->SetClientIPs($client_ips);

	    if (!$cg_cli->isSuccess) {
		my $args = [ { "cg_command_error" => 1,
			       "cg_cli" => $cg_cli
			     }];

		$c->detach( "Root", "end", $args );
	    }
	}


	my $whitehole_ips = $c->request->param('whitehole_ips');

	if ($whitehole_ips) {
	    $whitehole_ips =~ s/\s*;.*//g;
	    $whitehole_ips =~ s/^\s+$//g;
	    $whitehole_ips =~ s/\s+/ /g;
	    $whitehole_ips =~ s/\n/ /g;
	    $whitehole_ips =~ s/\s$//g;
	    $whitehole_ips =~ s/ /\\e/g;

	    $cg_cli->SetWhiteHoleIPs($whitehole_ips);

	    if (!$cg_cli->isSuccess) {
		my $args = [ { "cg_command_error" => 1,
			       "cg_cli" => $cg_cli
			     }];

		$c->detach( "Root", "end", $args );
	    }
	}


	my $nated_ips = $c->request->param('nated_ips');

	if ($nated_ips) {

	    $nated_ips =~ s/\s*;.*//g;
	    $nated_ips =~ s/^\s+$//g;
	    $nated_ips =~ s/\s+/ /g;
	    $nated_ips =~ s/\n/ /g;
	    $nated_ips =~ s/\s$//g;
	    $nated_ips =~ s/ /\\e/g;

	    $cg_cli->SetNATedIPs($nated_ips);

	    if (!$cg_cli->isSuccess) {
		my $args = [ { "cg_command_error" => 1,
			       "cg_cli" => $cg_cli
			     }];

		$c->detach( "Root", "end", $args );
	    }
	}


	my $lan_ips = $c->request->param('lan_ips');

	if ($lan_ips) {

	    $lan_ips =~ s/\s*;.*//g;
	    $lan_ips =~ s/^\s+$//g;
	    $lan_ips =~ s/\s+/ /g;
	    $lan_ips =~ s/\n/ /g;
	    $lan_ips =~ s/\s$//g;
	    $lan_ips =~ s/ /\\e/g;

	    $cg_cli->SetLANIPs($lan_ips);

	    if (!$cg_cli->isSuccess) {
		my $args = [ { "cg_command_error" => 1,
			       "cg_cli" => $cg_cli
			     }];

		$c->detach( "Root", "end", $args );
	    }
	}


	my $debug_ips = $c->request->param('debug_ips');

	if ($debug_ips) {

	    $debug_ips =~ s/\s*;.*//g;
	    $debug_ips =~ s/^\s+$//g;
	    $debug_ips =~ s/\s+/ /g;
	    $debug_ips =~ s/\n/ /g;
	    $debug_ips =~ s/\s$//g;
	    $debug_ips =~ s/ /\\e/g;

	    $cg_cli->SetDebugIPs($debug_ips);

	    if (!$cg_cli->isSuccess) {
		my $args = [ { "cg_command_error" => 1,
			       "cg_cli" => $cg_cli
			     }];

		$c->detach( "Root", "end", $args );
	    }
	}

    }

    $c->forward( 'IPAddresses', 'ip_addresses');
    $c->stash->{template}  = "ipaddresses/edit.tt2";
}

=head1 AUTHOR

Ivaylo Valkov <ivaylo@e-valkov.org>

=head1 LICENSE

Awaiting contractor approval.

=cut

__PACKAGE__->meta->make_immutable;

1;
