use strict;
use warnings;
use Test::More;


use Catalyst::Test 'cMailPro::TroubleShooter';
use cMailPro::TroubleShooter::Controller::Logs;

ok( request('/logs')->is_success, 'Request should succeed' );
done_testing();
