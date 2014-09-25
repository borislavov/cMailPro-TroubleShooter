package Template::Plugin::DecodeMailHeader;

use Encode;

use Template::Plugin::Filter;
use base qw( Template::Plugin::Filter );

sub filter {
    my ($self, $text) = @_;

    $text = encode_utf8(decode('MIME-Header', $text));

    return $text;
}

1;
