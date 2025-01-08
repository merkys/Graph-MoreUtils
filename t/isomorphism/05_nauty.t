#!/usr/bin/perl

use strict;
use warnings;

use Graph::MoreUtils qw( equitable_partitions );
use Graph::Undirected;
use Test::More tests => 5;

# Examples from https://pallini.di.uniroma1.it/Introduction.html

my $g;

# 8-vertex examples from "Refinement: equitable partition"

$g = Graph::Undirected->new;
$g->add_cycle( 1..8 );
$g->add_cycle( 3, 4, 7, 8 );

is scalar equitable_partitions( $g, sub { '' } ), 2;

$g = Graph::Undirected->new;
$g->add_cycle( 1..8 );
$g->add_cycle( 3, 4, 8, 7 );

is scalar equitable_partitions( $g, sub { '' } ), 2;

# Example from "Partition refinement"

$g = Graph::Undirected->new;
$g->add_cycle( 1..8 );
$g->add_cycle( 3, 4, 8, 7 );

is scalar equitable_partitions( $g, sub { $_[0] == 6 } ), 6;

# Example from "Equitable Partition and Orbit Partition - An Example", with and without coloring
# It seems that this case fails the algorithm

$g = Graph::Undirected->new;
$g->add_cycle( 1, 4, 9, 5, 2, 6, 10, 3 );
$g->add_path( 3, 7, 5 );
$g->add_path( 4, 8, 6 );
$g->add_edge( 7, 9 );
$g->add_edge( 8, 10 );

is scalar equitable_partitions( $g, sub { '' } ), 3;
is scalar equitable_partitions( $g, sub { $_[0] < 3 } ), 3;
