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

sub ip_addresses :Regex('^ip_addresses') {
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


=head1 AUTHOR

Ivaylo Valkov <ivaylo@e-valkov.org>

=head1 LICENSE

Awaiting contractor approval.

=cut

__PACKAGE__->meta->make_immutable;

1;
