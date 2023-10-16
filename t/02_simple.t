#!/usr/bin/perl

use strict;
use warnings;
use Graph::Smoothed;
use Graph::Undirected;
use Test::More tests => 8;

my( $g, $s, @edges );

# Path of three vertices, one edge has an attribute

$g = Graph::Undirected->new;
$g->add_path( 'A'..'Z' );

$s = Graph::Smoothed->new( $g );

is( $s->vertices, 2 );
is( $s->edges, 1 );
is( join( ',', @{$s->get_edge_attribute( 'A', 'Z', 'intermediate' )} ),
    join( ',', 'B'..'Y' ) );

$g = Graph::Undirected->new;
$g->add_path( 'Z', 'B'..'Y', 'A' );

$s = Graph::Smoothed->new( $g );

is( $s->vertices, 2 );
is( $s->edges, 1 );
is( join( ',', @{$s->get_edge_attribute( 'A', 'Z', 'intermediate' )} ),
    join( ',', reverse 'B'..'Y' ) );

$g = Graph::Undirected->new;
$g->add_edges( [ 'A', 'B' ], [ 'B', 'C' ], [ 'C', 'A' ] );

$s = Graph::Smoothed->new( $g );

is( $s->vertices, 3 );
is( $s->edges, 3 );
