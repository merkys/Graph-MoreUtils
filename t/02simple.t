#!/usr/bin/perl

use strict;
use warnings;
use Graph::Line;
use Graph::Undirected;
use Test::More tests => 7;

my( $g, $l, @edges );

$g = Graph::Undirected->new;
$g->add_edges( [ 'A', 'B' ], [ 'B', 'C' ] );
$g->set_edge_attribute( 'A', 'B', 'color', 'red' );

$l = Graph::Line->new( $g );

is( $l->vertices, 2 );
is( $l->edges, 1 );
is( (grep { defined $_->{color} && $_->{color} eq 'red' } $l->vertices), 1 );

@edges = $l->edges;
is( $l->get_edge_attribute( @{$edges[0]}, 'original_vertex' ), 'B' );

$l = Graph::Line->new( $g, { loop_end_vertices => 1 } );

is( $l->vertices, 4 );
is( $l->edges, 3 );

@edges = $l->edges;
is( join( ',', sort map { $l->get_edge_attribute( @$_, 'original_vertex' ) }
                        $l->edges ),
    'A,B,C' );
