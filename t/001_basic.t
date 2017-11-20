use strict;
use Test::More;
use_ok "Data::OpenGraph";

subtest 'basic' => sub {
    my $og = Data::OpenGraph->parse_string(<<EOM);
<meta property="og:title" content="foo bar baz">
EOM
    if (not is $og->property("title"), "foo bar baz") {
        diag($og);
    }
};

subtest 'nested' => sub {
    my $og = Data::OpenGraph->parse_string(<<EOM);
<meta property="og:audio:title" content="foo bar baz">
EOM
    if (not is $og->property("audio:title"), "foo bar baz") {
        diag($og);
    }
};

done_testing;