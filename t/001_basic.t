use strict;
use Test::More;
use_ok "Data::OpenGraph";
use Data::Dumper ();

local $Data::Dumper::Indent = 1;
local $Data::Dumper::Terse = 1;
local $Data::Dumper::Sortkeys = 1;

subtest 'basic' => sub {
    my $og = Data::OpenGraph->parse_string(<<EOM);
<meta property="og:title" content="foo bar baz">
EOM
    if (not is $og->property("title"), "foo bar baz") {
        diag(Data::Dumper::Dumper($og));
    }
};

subtest 'nested' => sub {
    my $og = Data::OpenGraph->parse_string(<<EOM);
<meta property="og:audio:title" content="foo bar baz">
EOM
    if (not is $og->property("audio:title"), "foo bar baz") {
        diag(Data::Dumper::Dumper($og));
    }
};

done_testing;