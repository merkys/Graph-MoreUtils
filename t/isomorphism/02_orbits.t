#!/usr/bin/perl

use strict;
use warnings;

use Algorithm::Combinatorics qw( combinations );
use Graph::MoreUtils qw( canonical_order orbits );
use Graph::Undirected;
use Test::More tests => 3;

my $g;

# Complete graph of 5 vertices

$g = Graph::Undirected->new;
$g->add_edges( combinations( [1..5], 2 ) );

is scalar orbits( $g, sub { '' } ), 1;

# Let us attach yet another vertex

$g->add_edge( 5, 6 );

is scalar orbits( $g, sub { '' } ), 3;

my @order = canonical_order( $g, sub { '' } );
is $order[-1], '6';
