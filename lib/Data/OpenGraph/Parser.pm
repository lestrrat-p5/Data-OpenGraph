package Data::OpenGraph::Parser;
use strict;
use HTML::Parser;
use Scalar::Util qw(reftype);


sub new {
    my $class = shift;
    my $parser = HTML::Parser->new(
        api_version => 3,
        start_h => [ sub {
            my ($self, $tag, $attr) = @_;

            return unless $tag eq 'meta';

            my $prop = $attr->{property};
            my $content = $attr->{content};
            return unless $prop && $content;
            my $properties = $self->{properties};
            my $basictype;
            return unless ($prop =~ /^og:/
                           || (exists $properties->{'type'}
                               && ($basictype = $properties->{'_basictype'}) ne ''
                               && $prop =~ /^(?:og:)?$basictype:.+$/));
            $prop =~ s/^og://;
            $basictype = $properties->{'_basictype'} if ! defined $basictype;
            if (defined $basictype
                && $basictype ne ''
                && $prop =~ /^(?:og:)?$basictype:.+$/) {
                if ($prop =~ /^$basictype:.+$/) {
                    if (exists $properties->{$prop}) {
                        if (reftype($properties->{$prop}) eq 'ARRAY') {
                            push @{$properties->{$prop}}, $content;
                        }
                        else {
                            $properties->{$prop} = [$properties->{$prop}, $content];
                        }
                    }
                    else {
                        $properties->{$prop} = $content;
                    }
                }
            }
            else {
                if ($prop eq 'type') {
                    if ($content =~ /^([^.]+)\..+$/) {
                        $properties->{'_basictype'} = $1;
                    } else {
                        $properties->{'_basictype'} = $content;
                    }
                }
                $properties->{$prop} = $content;
            }
        }, "self, tagname, attr" ],
    );
    return bless { parser => $parser }, $class;
}

sub parse_string {
    my ($self, $string) = @_;

    my %properties;
    my $parser = $self->{parser};
    local $parser->{properties} = \%properties;
    $parser->parse($string);
    $parser->eof;

    return \%properties;
}

1;
