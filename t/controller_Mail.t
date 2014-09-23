use strict;
use warnings;
use Test::More;


use Catalyst::Test 'cMailPro::TroubleShooter';
use cMailPro::TroubleShooter::Controller::Mail;

ok( request('/mail')->is_success, 'Request should succeed' );
done_testing();
