package Graph::Line;

use strict;
use warnings;

use Graph::Undirected;

# VERSION

sub new
{
    my( $graph, $options ) = @_;

    $options = {} unless $options;

    my @edges = $graph->edges;
    my $adjacency = {};
    for my $edge (@edges) {
        push @{$adjacency->{$edge->[0]}}, $edge;
        push @{$adjacency->{$edge->[1]}}, $edge;
    }

    my $line_graph = Graph::Undirected->new;
    $line_graph->add_vertices( @edges );
    for my $vertex (sort keys %$adjacency) {
        for my $i (0..$#${$adjacency->{$vertex}}-1) {
            for my $j ($i+1..$#${$adjacency->{$vertex}}) {
                $line_graph->add_edge( $adjacency->{$vertex}[$i],
                                       $adjacency->{$vertex}[$j] );
            }
        }
    }

    return $line_graph;
}

1;
