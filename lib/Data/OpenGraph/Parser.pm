package Data::OpenGraph::Parser;
use strict;
use Scalar::Util qw(reftype blessed);


sub new {
    my ($class, %args) = @_;
    my $self = bless {
        libxml => ($args{libxml} // 1) ? 1 : undef
    }, $class;
}

sub parse_string {
    my ($self, $string) = @_;

    my $tree;
    if ($self->{libxml}) {
        use HTML::TreeBuilder::LibXML;
        $tree = HTML::TreeBuilder::LibXML->new();
    }
    else {
        use HTML::TreeBuilder::XPath;
        $tree = HTML::TreeBuilder::XPath->new();
    }

    $tree->parse($string);
    $tree->eof;

    my %properties = ();

    my $og_type = $tree->findnodes('//meta[@property="og:type" and @content]');
    if (defined($og_type)) {
        $og_type = _unwrap_one_node($og_type);
    }

    my $content;
    if (defined($og_type)
        && ($content = $og_type->attr('content'))) {
        $properties{'type'} = $content;
        if ($content =~ /^([^.]+)\..+$/) {
            $properties{'_basictype'} = $1;
        } else {
            $properties{'_basictype'} = $content;
        }
    }
    my $basictype = $properties{'_basictype'};

    my $metas = $tree->findnodes(
        '//meta['
        .'((starts-with(@property, "og:") and @property != "og:type")'
        .(defined($basictype)
          ? ' or starts-with(@property, "'.$basictype.':")' : '')
        .')'
        .'and @content'
        .']');
    for my $meta (@$metas) {
        my $prop = $meta->attr('property');
        $content = $meta->attr('content');
        next unless $prop && $content;
        $prop =~ s/^og://;
        if ($prop =~ /^$basictype:.+$/) {
            if (exists $properties{$prop}) {
                if ((reftype($properties{$prop}) // '') eq 'ARRAY') {
                    push @{$properties{$prop}}, $content;
                }
                else {
                    $properties{$prop} = [$properties{$prop}, $content];
                }
            }
            else {
                $properties{$prop} = $content;
            }
        }
        else {
            $properties{$prop} = $content;
        }
    }

    $tree->delete;
    return \%properties;
}

sub _unwrap_one_node {
    # There appears to be a slight difference in return value depending on
    # whether HTML::TreeBuilder::LibXML or HTML::TreeBuilder::XPath is used.

    my ($nodes_or_node,) = @_;
    if (blessed($nodes_or_node)
        && $nodes_or_node->isa('XML::XPathEngine::NodeSet')) {
        if ($nodes_or_node->size()) {
            return $nodes_or_node->get_node(0);
        }
        else {
            return;
        }
    }
    elsif (reftype($nodes_or_node) eq 'ARRAY') {
        if (scalar @$nodes_or_node) {
            return $nodes_or_node->[0];
        }
        else {
            return;
        }
    }

    return $nodes_or_node;
}

1;


# Local Variables:
# mode: cperl
# cperl-indent-parens-as-block: t
# cperl-indent-level: 4
# cperl-close-paren-offset: -4
# cperl-continued-statement-offset: 0
# cperl-tab-always-indent: t
# End:
