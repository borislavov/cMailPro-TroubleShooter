package cMailPro::TroubleShooter::Controller::Logs;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

cMailPro::TroubleShooter::Controller::Logs - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

  List log topics/directories.

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    use Data::Dumper;

    my $cg_ts_api = new $c->model('CommuniGate::cMailProTSAPI');
    my $topics = $cg_ts_api->fetch('/logs/topics');
    my $overview = [];
    my $total_logs = 0;
    my $total_size = 0;

    for my $t (@{$topics->{logs}->{topics}}) {
	my $count = $cg_ts_api->fetch('/logs/count/'.$t);
	my $size = $count->{logs}->{count}->{size};
	$total_size += $size;
	$count = $count->{logs}->{count}->{count};
	push @{$overview}, { topic => $t, logs => $count, size => $size };
	$total_logs += $count;

    }

    $c->stash->{total_size} = $total_size;
    $c->stash->{total_logs} = $total_logs;
    $c->stash->{logs_overview} = $overview;
}


=head2 topic

 List log files in topic/directory.

=cut

sub topic :LocalRegexp('^(?!(~.*$))topic/(.*)') {
    my ( $self, $c ) = @_;

    my $topic = $c->request->captures->[1];
    my $cg_ts_api = new $c->model('CommuniGate::cMailProTSAPI');
    my $topic_api = $cg_ts_api->fetch('/logs/by_topic/'. $topic);

    if ($topic_api && $topic_api->{logs}->{by_topic}) {
        $c->stash->{logs_by_topic} = $topic_api->{logs}->{by_topic}->{logs} ;
        $c->stash->{log_topic} = $topic_api->{logs}->{by_topic}->{topic} ;
    } else {
	$c->response->status(404);
	$c->stash->{error_msg} = [ "Topic " . $topic." not found" ];
    }

    if ( $topic_api->{error} ) {
	$c->response->status(500);
	$c->stash->{error_msg} = [ $topic_api->{error} ];
	$c->stash->{status_msg} = ["Internal Server Error. CGI API communication error."];
    }
}

=head2 file

 View and download log files

=cut

sub file :LocalRegexp("^(?!(~.*$))(file|download)/(.*)") {
    my ( $self, $c ) = @_;
    my $filter = $c->request->param("filter");
    my $file = $c->request->captures->[2];
    my $rel_path = $c->request->captures->[1];

    my $cg_ts_api = new $c->model('CommuniGate::cMailProTSAPI');
    my $file_api = $cg_ts_api->fetch('/logs/file/'. $file, $filter);

    if ($file_api && $file_api->{logs}->{file}) {
	if ($rel_path eq 'download') {
	    $file =~ s/\//-/g;
	    $c->res->header('Content-Disposition', qq[attachment; filename="$file"]);
	    $c->res->content_type('text/plain');
	    $c->response->body (join("\n", @{$file_api->{logs}->{file}})) ;
	} else {
	    $c->stash->{log_file_contents} = $file_api->{logs}->{file} ;
	    $c->stash->{log_file} = $file;
	    $c->stash->{log_file_filter} = $filter;
	}
    } else {
	$c->response->status(404);
	$c->stash->{error_msg} = [ "File " . $file." not found" ];
    }

    if ( $file_api->{error} ) {
	$c->response->status(500);
	$c->stash->{error_msg} = [ $file_api->{error} ];
	$c->stash->{status_msg} = ["Internal Server Error. CGI API communication error."];
    }
}

=head2 realtime

  Realtime logs

=cut

sub realtime :LocalRegexp('^(?!(~.*$))realtime$') {
    my ( $self, $c ) = @_;

    my $cg_ts_api = new $c->model('CommuniGate::cMailProTSAPI');
    my $topics_api = $cg_ts_api->fetch('/logs/topics');

    if ( $topics_api->{error} ) {
	$c->response->status(500);
	$c->stash->{error_msg} = [ $topics_api->{error} ];
	$c->stash->{status_msg} = ["Internal Server Error. CGI API communication error."];
    }


    $c->stash->{realtime_topics} = $topics_api->{logs}->{topics};
}


=head2 realtime_single_topic

  Realtime logs

=cut

sub realtime_single_topic :LocalRegexp('^(?!(~.*$))realtime/([a-zA-Z0-9]+)(\/)*(seek\/([0-9]+))*') {
    my ( $self, $c ) = @_;

    my $topic = $c->request->captures->[1];
    my $seek = $c->request->captures->[4];
    my $filter = $c->request->param("filter");
    my $cg_ts_api = new $c->model('CommuniGate::cMailProTSAPI');
    my $rt_api = $cg_ts_api->fetch('/logs/realtime/'. $topic .($seek ? '/seek/'.$seek : ''),  $filter);

    if ($rt_api && $rt_api->{logs}->{realtime}) {
        $c->stash->{realtime} = $rt_api->{logs}->{realtime};
    } else {
	$c->response->status(404);
	$c->stash->{error_msg} = [ "Topic " . $topic." not found" ];
    }

    if ( $rt_api->{error} ) {
	$c->response->status(500);
	$c->stash->{error_msg} = [ $rt_api->{error} ];
	$c->stash->{status_msg} = ["Internal Server Error. CGI API communication error."];
    }
}


=head2 search

  Search in logs

=cut

sub search :LocalRegex('^~search(/)*(.*)') {
    my ( $self, $c ) = @_;

    my $search = $c->request->captures->[1];

    if ($c->request->method eq "POST") {
	$search = $c->request->param("search_pattern");
    }

    if (!$search) {
	$c->detach( "Root", "end");
    }

    my $cg_ts_api = new $c->model('CommuniGate::cMailProTSAPI');
    my $search_api = $cg_ts_api->fetch('/logs/search/'. $search);

    if ($search_api && $search_api->{logs}->{search}) {
        $c->stash->{search_logs} = $search_api->{logs}->{search};
    } else {
	$c->response->status(404);
	$c->stash->{error_msg} = [ "Pattern " . $search." not found" ];
    }

    if ( $search_api->{error} ) {
	$c->response->status(500);
	$c->stash->{error_msg} = [ $search_api->{error} ];
	$c->stash->{status_msg} = ["Internal Server Error. CGI API communication error."];
    }

}

=head1 AUTHOR

Ivaylo Valkov <ivaylo@e-valkov.org>

=head1 LICENSE

Awaiting contractor approval.

=cut

__PACKAGE__->meta->make_immutable;

1;
