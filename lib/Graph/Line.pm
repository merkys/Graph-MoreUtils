package Graph::Line;

use strict;
use warnings;

use parent 'Graph::Undirected';

use Graph::Undirected;

# VERSION

sub new
{
    my( $class, $graph, $options ) = @_;

    $options = {} unless $options;

    my @edges = map { { orig => $_,
                        attr => $graph->get_edge_attributes( @$_ ) } }
                    $graph->edges;
    my $adjacency = {};
    for my $edge (@edges) {
        push @{$adjacency->{$edge->{orig}[0]}}, $edge;
        push @{$adjacency->{$edge->{orig}[1]}}, $edge;
    }

    # Create the line graph
    my $line_graph = Graph::Undirected->new;
    $line_graph->add_vertices( @edges );
    for my $vertex (sort keys %$adjacency) {
        for my $i (0..$#{$adjacency->{$vertex}}-1) {
            for my $j ($i+1..$#{$adjacency->{$vertex}}) {
                $line_graph->add_edge( $adjacency->{$vertex}[$i],
                                       $adjacency->{$vertex}[$j] );
            }
        }
    }

    # Leave only old edge attributes in new vertices
    for my $vertex ($line_graph->vertices) {
        my $attr = $vertex->{attr};
        delete $vertex->{attr};
        delete $vertex->{orig};
        next if !defined $attr;
        %$vertex = %$attr;
    }

    return bless $line_graph, $class;
}

1;
