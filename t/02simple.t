#!/usr/bin/perl

use strict;
use warnings;
use Graph::Line;
use Graph::Undirected;
use Test::More tests => 3;

my( $g, $l );

$g = Graph::Undirected->new;
$g->add_edges( [ 'A', 'B' ], [ 'B', 'C' ] );
$g->set_edge_attribute( 'A', 'B', 'color', 'red' );

$l = Graph::Line->new( $g );

is( $l->vertices, 2 );
is( $l->edges, 1 );
is( (grep { defined $_->{color} && $_->{color} eq 'red' } $l->vertices), 1 );
