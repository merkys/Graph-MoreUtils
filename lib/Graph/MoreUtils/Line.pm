package Graph::MoreUtils::Line;

# ABSTRACT: Generate line graphs
# VERSION

use strict;
use warnings;

use Algorithm::Combinatorics qw( combinations );
use Graph;
use Graph::MoreUtils::Line::SelfLoopVertex;
use Graph::Undirected;
use Scalar::Util qw( blessed );

sub line
{
    my( $graph, $options ) = @_;

    if( !blessed $graph || !$graph->isa( Graph:: ) ) {
        die 'only Graph and its derivatives are accepted' . "\n";
    }

    $options = {} unless $options;

    my $line_graph = $graph->copy;

    # Add the edges as vertices to the edge graph
    if( $graph->is_multiedged ) {
    } else {
        for my $edge ($graph->edges) {
            my $edge_vertex = $graph->get_edge_attributes( @$edge ) || {};
            $line_graph->delete_edge( @$edge );
            $line_graph->add_path( $edge->[0], $edge_vertex, $edge->[1] );
        }
    }

    # Interconnect edge vertices which share the original vertex
    for my $vertex ($graph->vertices) {
        if( $graph->is_directed ) {
            for my $in ($line_graph->predecesors( $vertex )) {
                for my $out ($line_graph->successors( $vertex )) {
                    $line_graph->add_edge( $in, $out );
                }
            }
        } else {
            # TODO: Check for self-loops
            next if $line_graph->degree( $vertex ) < 2;
            $line_graph->add_edges( combinations( [ $line_graph->neighbours( $vertex ) ], 2 ) );
        }
    }

    $line_graph->delete_vertices( $graph->vertices );

    # Add self-loops for end vertices if requested
    #~ if( $options->{loop_end_vertices} ) {
        #~ for my $vertex ($graph->vertices) {
            #~ next if $graph->degree( $vertex ) != 1;
            #~ # Adjacency matrix will only have one item
            #~ $line_graph->set_edge_attribute( $adjacency->{$vertex}[0],
                                             #~ Graph::MoreUtils::Line::SelfLoopVertex->new,
                                             #~ 'original_vertex',
                                             #~ $vertex );
        #~ }
    #~ }

    return $line_graph;
}

1;
