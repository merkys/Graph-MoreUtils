package Graph::MoreUtils::Smoothed;

use strict;
use warnings;

use Graph::MoreUtils::Smoothed::Intermediate;
use Graph::Undirected;
use Scalar::Util qw( blessed );

use parent Graph::Undirected::;

# ABSTRACT: Generate smoothed graphs
# VERSION

sub new
{
    my( $class, $graph ) = @_;

    if( !blessed $graph || !$graph->isa( Graph::Undirected:: ) ) {
        die 'only Graph::Undirected and its derivatives accepted' . "\n";
    }

    my $graph_now = $graph->copy;
    for ($graph_now->vertices) {
        next unless $graph_now->degree( $_ ) == 2;
        my( $a, $b ) = sort $graph_now->neighbours( $_ );

        # do not reduce cycles of three vertices:
        next if $graph_now->has_edge( $a, $b );

        my $intermediate;
        if( $graph_now->has_edge_attribute( $a, $_, 'intermediate' ) &&
            $graph_now->has_edge_attribute( $b, $_, 'intermediate' ) ) {
            $intermediate = Graph::MoreUtils::Smoothed::Intermediate->new(
                $_ lt $a
                    ? $graph_now->get_edge_attribute( $a, $_, 'intermediate' )->reverse
                    : $graph_now->get_edge_attribute( $a, $_, 'intermediate' ),
                $_,
                $_ gt $b
                    ? $graph_now->get_edge_attribute( $b, $_, 'intermediate' )->reverse
                    : $graph_now->get_edge_attribute( $b, $_, 'intermediate' ) );
        } elsif( $graph_now->has_edge_attribute( $a, $_, 'intermediate' ) ) {
            $intermediate = $graph_now->get_edge_attribute( $a, $_, 'intermediate' );
            $intermediate->reverse if $a gt $_; # getting natural order
            push @$intermediate, $_;
        } elsif( $graph_now->has_edge_attribute( $b, $_, 'intermediate' ) ) {
            $intermediate = $graph_now->get_edge_attribute( $b, $_, 'intermediate' );
            $intermediate->reverse if $_ gt $b; # getting natural order
            unshift @$intermediate, $_;
        } else {
            $intermediate = Graph::MoreUtils::Smoothed::Intermediate->new( $_ );
        }

        $graph_now->delete_vertex( $_ );
        $graph_now->set_edge_attribute( $a, $b, 'intermediate', $intermediate );
    }

    return bless $graph_now, $class;
}

1;
