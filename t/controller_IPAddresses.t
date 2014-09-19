use strict;
use warnings;
use Test::More;


use Catalyst::Test 'cMailPro::TroubleShooter';
use cMailPro::TroubleShooter::Controller::IPAddresses;

ok( request('/ipaddresses')->is_success, 'Request should succeed' );
done_testing();
