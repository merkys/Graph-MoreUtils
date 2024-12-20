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

    my $line_graph = Graph->new( directed => $graph->is_directed,
                                 refvertexed => 1 );

    # Add the edges as vertices to the edge graph
    if( $graph->is_multiedged ) {
        for my $unique_edge ($graph->unique_edges) {
            for my $edge ($graph->get_multiedge_ids( @$unique_edge )) {
                my $edge_vertex = $graph->get_edge_attributes_by_id( @$unique_edge, $edge ) || {};
                $line_graph->add_path( $unique_edge->[0], $edge_vertex, $unique_edge->[1] );
            }
        }
    } else {
        for my $edge ($graph->edges) {
            my $edge_vertex = $graph->get_edge_attributes( @$edge ) || {};
            $line_graph->add_path( $edge->[0], $edge_vertex, $edge->[1] );
        }
    }

    # Interconnect edge vertices which share the original vertex
    for my $vertex ($graph->vertices) {
        if( $graph->is_directed ) {
            for my $in ($line_graph->predecessors( $vertex )) {
                for my $out ($line_graph->successors( $vertex )) {
                    $line_graph->set_edge_attribute( $in,
                                                     $out,
                                                     'original_vertex',
                                                     $vertex );
                }
            }
        } else {
            # TODO: Check for self-loops
            next if $line_graph->degree( $vertex ) < 2;
            for my $edge (combinations( [ $line_graph->neighbours( $vertex ) ], 2 )) {
                $line_graph->set_edge_attribute( @$edge, 'original_vertex', $vertex );
            }
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
