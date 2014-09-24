package cMailPro::TroubleShooter::Controller::Mail;
use Moose;
use namespace::autoclean;
use LWP::UserAgent;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

cMailPro::TroubleShooter::Controller::Mail - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

 Redirects to message list

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    
    $c->response->redirect( $c->uri_for('/mail/messages'), 302 );
}

=head2 messages

 List all messages in the queue.

=cut

sub messages :LocalRegexp('^(?!(~.*$))messages$') {
    my ( $self, $c ) = @_;

    my $cg_ts_api = new $c->model('CommuniGate::cMailProTSAPI');
    my $messages = $cg_ts_api->fetch('/messages');

    $c->stash->{messages} = $messages->{messages} unless !$messages->{messages};

    if ( $messages->{error} ) {
	$c->response->status(500);
	$c->stash->{error_msg} = [ $messages->{error} ];
	$c->stash->{status_msg} = ["Internal Server Error. CGI API communication error."];
    }
}

=head2  message

 View single message in the queue.

=cut 

sub message :LocalRegexp("^(?!(~.*$))messages/(.*)") {
    my ( $self, $c ) = @_;

    my $message_id = $c->request->captures->[1];

    my $cg_ts_api = new $c->model('CommuniGate::cMailProTSAPI');
    my $message = $cg_ts_api->fetch('/messages/'. $message_id);

    if ($message && $message->{message}) {
        $c->stash->{message} = $message->{message} ;
    } else {
	$c->response->status(404);
	$c->stash->{error_msg} = [ "Message " . $message_id." not found" ];
    }

    if ( $message->{error} ) {
	$c->response->status(500);
	$c->stash->{error_msg} = [ $message->{error} ];
	$c->stash->{status_msg} = ["Internal Server Error. CGI API communication error."];
    }
}

=head2

  Release single queue.

=cut


sub release_single :LocalRegex('^release/(.*)') {
    my ( $self, $c ) = @_;

    my $queue_id = $c->request->captures->[0];

    if (!$queue_id) {
	$c->response->status(500);
	$c->stash->{status_msg}  = [ 'Missing parameter' ] ;
	$c->stash->{error_msg}  = [ 'Queue/domain id is required for release to work.' ] ;
	$c->detach( 'Root', 'end' );
    }

    my $released_queue = { id => $queue_id, released => 0, confirmed => 0 };

    if ($c->request->method eq 'POST' &&
	$c->request->param('confirm_release_1') &&
	$c->request->param('confirm_release_2') ) {
	$released_queue->{confirmed} = 1;

	my $cg_cli = new $c->model("CommuniGate::CLI")->connect();

	if (!$cg_cli) {
	    my $cg_err_args = [ { "cg_connection_error" => 1,
				  "cg_cli" => $cg_cli
				}];

	    $c->detach( "Root", "end", $cg_err_args );
	}

	$cg_cli->ReleaseSMTPQueue($queue_id);

	if (!$cg_cli->isSuccess) {
	    my $cg_err_args = [ { "cg_command_error" => 1,
				  "cg_cli" => $cg_cli
				}];

	    $c->detach( "Root", "end", $cg_err_args );
	}

	$released_queue->{released} = 1;
    }

    $c->stash->{released_queue} = $released_queue;
}


=head2 release

 Find queue/domain to release.

=cut

sub release :LocalRegex('^release$') {
    my ( $self, $c ) = @_;

    my $queue_id = $c->request->param('queue');

    if ($c->request->method eq 'POST' && $queue_id) {

	my $cg_cli = new $c->model("CommuniGate::CLI")->connect();

	if (!$cg_cli) {
	    my $cg_err_args = [ { "cg_connection_error" => 1,
				  "cg_cli" => $cg_cli
				}];

	    $c->detach( "Root", "end", $cg_err_args );
	}

	my $domain = $cg_cli->GetDomainEffectiveSettings($queue_id);

	if (!$cg_cli->isSuccess) {

	    if ($cg_cli->getErrCode != 512) {

		my $cg_err_args = [ { "cg_command_error" => 1,
				      "cg_cli" => $cg_cli
				    }];

		$c->detach( "Root", "end", $cg_err_args );
	    } else {
		$c->stash->{queue_does_not_exist} = 1;
		$c->detach( "Root", "end");
	    }
	}

	$c->response->redirect( $c->uri_for("release/".$queue_id), 302 );
    }
}

=head2 reject

  Find existing message to reject from mail queue.

=cut

sub reject :LocalRegex('^reject$') {
    my ( $self, $c ) = @_;
    my $message_id = $c->request->param('message');

    if ($message_id && $message_id !~ m/\d+/) {
	$c->stash->{message_does_not_exist} = '1';
	undef $message_id;
    }

    if ($c->request->method eq 'POST' && $message_id) {

	my $cg_ts_api = new $c->model('CommuniGate::cMailProTSAPI');
	my $res = $cg_ts_api->fetch('/message_exists/'.$message_id);

	if (defined $res->{message_exists} &&
	    $res->{message_exists}) {
	    $c->response->redirect( $c->uri_for("reject/".$message_id), 302 );
	} else {
	    $c->stash->{message_does_not_exist} = '1';
	}
    }
}

=head2 reject_single

 Reject single message in the queue

=cut

sub reject_single :LocalRegex('^reject/(.*)') {
    my ( $self, $c ) = @_;

    my $message_id = $c->request->captures->[0];

    if (!$message_id) {
	$c->response->status(500);
	$c->stash->{status_msg}  = [ 'Missing parameter' ] ;
	$c->stash->{error_msg}  = [ 'Message id is required for rejection to work.' ] ;
	$c->detach( 'Root', 'end' );
    }

    my $rejected_message = { id => $message_id, rejected => 0, confirmed => 0 };

    if ($c->request->method eq 'POST' &&
	$c->request->param('confirm_reject_1') &&
	$c->request->param('confirm_reject_2') ) {
	$rejected_message->{confirmed} = 1;

	my $cg_cli = new $c->model("CommuniGate::CLI")->connect();

	if (!$cg_cli) {
	    my $cg_err_args = [ { "cg_connection_error" => 1,
				  "cg_cli" => $cg_cli
				}];

	    $c->detach( "Root", "end", $cg_err_args );
	}

	$cg_cli->RejectQueueMessage($message_id);

	if (!$cg_cli->isSuccess) {
	    my $cg_err_args = [ { "cg_command_error" => 1,
				  "cg_cli" => $cg_cli
				}];

	    $c->detach( "Root", "end", $cg_err_args );
	}

	$rejected_message->{rejected} = 1;
    }

    $c->stash->{rejected_message} = $rejected_message;
}

=head2 reject_all

  Reject all messages in the queue

=cut

sub reject_all :LocalRegex('^reject_all') {
    my ( $self, $c ) = @_;

    my $rejected_messages = [];

    if ($c->request->method eq 'POST' &&
	$c->request->param('confirm_reject_1') &&
	$c->request->param('confirm_reject_2') ) {

	my $cg_cli = new $c->model("CommuniGate::CLI")->connect();

	if (!$cg_cli) {
	    my $cg_err_args = [ { "cg_connection_error" => 1,
				  "cg_cli" => $cg_cli
				}];

	    $c->detach( "Root", "end", $cg_err_args );
	}

	my $cg_ts_api = new $c->model('CommuniGate::cMailProTSAPI');
	my $messages = $cg_ts_api->fetch('/messages');

	if ( $messages->{error} ) {
	    $c->response->status(500);
	    $c->stash->{error_msg} = [ $messages->{error} ];
	    $c->stash->{status_msg} = ["Internal Server Error. CGI API communication error."];
	    $c->detach( "Root", "end" );
	}

	for my $m (@{$messages->{messages}}) {
	    my $message_id = $m->{id};

	    my $rejected_message = { id => $message_id, rejected => 0, confirmed => 1 };

	    $cg_cli->RejectQueueMessage($message_id);

	    if (!$cg_cli->isSuccess) {
		$rejected_message->{error} = $cg_cli->getErrMessage;
	    } else {
		$rejected_message->{rejected} = 1;
	    }

	    push @$rejected_messages, $rejected_message;
	}
    }

    $c->stash->{rejected_messages} = $rejected_messages;
}


=head2 release_all

  Release all queues

=cut

sub release_all :LocalRegex('^release_all') {
    my ( $self, $c ) = @_;

    my $released_queues = [];

    if ($c->request->method eq 'POST' &&
	$c->request->param('confirm_release_1') &&
	$c->request->param('confirm_release_2') ) {

	my $cg_cli = new $c->model("CommuniGate::CLI")->connect();

	if (!$cg_cli) {
	    my $cg_err_args = [ { "cg_connection_error" => 1,
				  "cg_cli" => $cg_cli
				}];

	    $c->detach( "Root", "end", $cg_err_args );
	}

	my $queues = $cg_cli->ListDomains();

	if (!$cg_cli->isSuccess) {
	    my $cg_err_args = [ { "cg_command_error" => 1,
				  "cg_cli" => $cg_cli
				}];

	    $c->detach( "Root", "end", $cg_err_args );
	}

	for my $queue (@$queues) {
	    my $released_queue = { id => $queue, released => 0, confirmed => 1 };

	    $cg_cli->ReleaseSMTPQueue($queue);

	    if (!$cg_cli->isSuccess) {
		$released_queue->{error} = $cg_cli->getErrQueue;
	    } else {
		$released_queue->{released} = 1;
	    }

	    push @$released_queues, $released_queue;
	}
    }

    $c->stash->{released_queues} = $released_queues;
}

=head1 AUTHOR

Ivaylo Valkov <ivaylo@e-valkov.org>

=head1 LICENSE

Awaiting approval by contractor.

=cut

__PACKAGE__->meta->make_immutable;

1;
