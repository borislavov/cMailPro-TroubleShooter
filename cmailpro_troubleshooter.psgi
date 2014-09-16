use strict;
use warnings;

use cMailPro::TroubleShooter;

my $app = cMailPro::TroubleShooter->apply_default_middlewares(cMailPro::TroubleShooter->psgi_app);
$app;

