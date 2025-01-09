#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
use Graph::MoreUtils qw( equitable_partition orbits );
use Graph::Undirected;

# Graph from "Node invariants and pruning"
my $g1 = Graph::Undirected->new;
$g1->add_cycle( 0, 1, 2, 5, 8, 7, 6, 3 );
$g1->add_cycle( 1, 3, 7, 5 );
$g1->add_path( 1, 4, 7 );
$g1->add_path( 3, 4, 5 );

my %g1_colors;
for ($g1->vertices) {
    $g1_colors{$_} = 0 if $g1->degree( $_ ) == 5;
    $g1_colors{$_} = 1 if $g1->degree( $_ ) == 2;
    $g1_colors{$_} = 2 if $g1->degree( $_ ) == 4;
}

# Graph from "Equitable Partition and Orbit Partition - An Example"
my $g2 = Graph::Undirected->new;
$g2->add_cycle( '01', '04', '09', '05', '02', '06', '10', '03' );
$g2->add_path( '03', '07', '05' );
$g2->add_path( '04', '08', '06' );
$g2->add_edge( '07', '09' );
$g2->add_edge( '08', '10' );

my %g2_colors;
for ($g2->vertices) {
    $g2_colors{$_} = 0 + ($_ > 2);
}

# Graph from https://pallini.di.uniroma1.it/SearchTree.html
my $g3 = Graph::Undirected->new;
$g3->add_cycle( 0..4 );
$g3->add_cycle( 5, 7, 9, 6, 8 );
for (0..4) {
    $g3->add_edge( $_, 5 + $_ );
}

my %g3_colors;
for ($g3->vertices) {
    $g3_colors{$_} = 0;
}

print Dumper [ orbits( $g2, sub { $g2_colors{$_[0]} } ) ];
