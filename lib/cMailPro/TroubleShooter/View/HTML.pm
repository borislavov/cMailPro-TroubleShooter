package cMailPro::TroubleShooter::View::HTML;

use strict;
use warnings;

use base 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt2',
    INCLUDE_PATH => [
	cMailPro::TroubleShooter->path_to('root', 'src'),
    ],
    TIMER => 0,
    WRAPPER => 'wrapper.tt2',
    render_die => 1,
);

=head1 NAME

cMailPro::TroubleShooter::View::HTML - TT View for cMailPro::TroubleShooter

=head1 DESCRIPTION

TT View for cMailPro::TroubleShooter.

=head1 SEE ALSO

L<cMailPro::TroubleShooter>

=head1 AUTHOR

Ivaylo Valkov <ivaylo@e-valkov.org>

=head1 LICENSE

Awaiting contractor approval.

=cut

1;
