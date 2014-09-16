use strict;
use warnings;
use Test::More;


use Catalyst::Test 'cMailPro::TroubleShooter';
use cMailPro::TroubleShooter::Controller::Domains;

ok( request('/domains')->is_success, 'Request should succeed' );
done_testing();
