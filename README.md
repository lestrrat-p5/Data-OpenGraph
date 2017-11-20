# NAME

Data::OpenGraph - Parse OpenGraph Contents

# SYNOPSIS

    use Data::OpenGraph;

    my $og = Data::OpenGraph->parse_uri( "http://some.content/with/opengraph.html" );

    my $ua = LWP::UserAgent->new();
    my $res = $ua->get( "http://some.content/with/opengraph.html" );
    my $og = Data::OpenGraph->parse_uri( $res->decoded_content );

    my $title = $og->property( "title" );
    my $type  = $og->property( "type" );

# DESCRIPTION

WARNINGS: ALPHA CODE! Probably very incomplete. Please send pull-reqs if you would like this module to be better

Data::OpenGraph is a simple Opengraph ( http://ogp.me ) parser. It just parses some HTML looking for meta tags with property attribute that looks like "og:.+".

Currently nested attributes such as "audio:title", "audio:artist" are store verbatim, so you need to access them like:

    $og->property( "audio:title" );
    $og->property( "audio:artist" );

# METHODS

## Data::OpenGraph->new(properties => \\%properties)

Creates a new OpenGraph container. You probably won't be using this much.

## Data::OpenGraph->parse\_string( $string )

Creates a new OpenGraph container by parsing $string.

## Data::OpenGraph->parse\_uri( $uri )

Fetches the uri, then creates a new OpenGraph container by parsing the content. On HTTP errors, this method will croak. 

# SEE ALSO

[RDF::RDFa::Parser](https://metacpan.org/pod/RDF::RDFa::Parser)

# AUTHOR

Daisuke Maki `<daisuke@endeworks.jp>`

# COPYRIGHT AND LICENSE

Copyright (C) 2011 by Daisuke Maki

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.0 or,
at your option, any later version of Perl 5 you may have available.
