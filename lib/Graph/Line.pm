package Graph::Line;

use strict;
use warnings;

use parent 'Graph::Undirected';

use Graph::Undirected;

# ABSTRACT: Generate line graphs
# VERSION

sub new
{
    my( $class, $graph, $options ) = @_;

    $options = {} unless $options;

    my @edges;
    if( $graph->is_multiedged ) {
        for my $unique_edge ($graph->unique_edges) {
            for my $edge ($graph->get_multiedge_ids( @$unique_edge )) {
                push @edges, {
                        orig => $unique_edge,
                        attr => $graph->get_edge_attributes_by_id( @$unique_edge,
                                                                   $edge )
                     };
            }
        }
    } else {
        @edges = map { { orig => $_,
                         attr => $graph->get_edge_attributes( @$_ ) } }
                     $graph->edges;
    }

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
                $line_graph->set_edge_attribute( $adjacency->{$vertex}[$i],
                                                 $adjacency->{$vertex}[$j],
                                                 'original_vertex',
                                                 $vertex );
            }
        }
    }

    # Add self-loops for end vertices if requested
    if( $options->{loop_end_vertices} ) {
        for my $vertex ($graph->vertices) {
            next if $graph->degree( $vertex ) != 1;
            # Adjacency matrix will only have one item
            $line_graph->set_edge_attribute( $adjacency->{$vertex}[0],
                                             {},
                                             'original_vertex',
                                             $vertex );
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
