#!/usr/bin/perl

use strict;
use warnings;

use Graph::MoreUtils qw( equitable_partitions );
use Graph::Undirected;
use Test::More;

# All asymmetric 6-numbered graphs
# From https://en.wikipedia.org/w/index.php?title=Asymmetric_graph&oldid=1251673484
# All graphs enumerated in https://commons.wikimedia.org/w/index.php?title=File:Asym-graph.PNG&oldid=805788206

plan tests => 8;

my $g1 = Graph::Undirected->new;
$g1->add_path( 1..6 );
$g1->add_path( 2, 4 );

my $g2 = Graph::Undirected->new;
$g2->add_path( 1..6 );
$g2->add_path( 4, 2, 5 );

my $g3 = Graph::Undirected->new;
$g3->add_path( 1..6 );
$g3->add_path( 1, 5, 2 );

my $g4 = Graph::Undirected->new;
$g4->add_path( 1..6 );
$g4->add_path( 1, 5, 2, 4 );

my $g5 = Graph::Undirected->new;
$g5->add_path( 1..6, 2 );
$g5->add_path( 4, 6 );

my $g6 = Graph::Undirected->new;
$g6->add_cycle( 1..6 );
$g6->add_path( 4, 2, 5 );

my $g7 = Graph::Undirected->new;
$g7->add_path( 1..5, 1, 6 );
$g7->add_path( 4, 2, 5 );

my $g8 = Graph::Undirected->new;
$g8->add_cycle( 1..6, 1 );
$g8->add_path( 4, 1, 5, 3 );

my @graphs = ( $g1, $g2, $g3, $g4, $g5, $g6, $g7, $g8 );
for (@graphs) {
    is scalar equitable_partitions( $_, sub { '' } ), 6;
}
