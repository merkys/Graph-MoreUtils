#!/usr/bin/perl

use strict;
use warnings;

use Graph::MoreUtils qw( equitable_partition orbits );
use Graph::Undirected;
use Test::More tests => 2;

# Graph from https://pallini.di.uniroma1.it/Introduction.html "Node invariants and pruning"

my $g = Graph::Undirected->new;
$g->add_cycle( 0, 1, 2, 5, 8, 7, 6, 3 );
$g->add_cycle( 1, 3, 7, 5 );
$g->add_path( 1, 4, 7 );
$g->add_path( 3, 4, 5 );

my %colors;
for ($g->vertices) {
    $colors{$_} = 0 if $g->degree( $_ ) == 5;
    $colors{$_} = 1 if $g->degree( $_ ) == 2;
    $colors{$_} = 2 if $g->degree( $_ ) == 4;
}

is scalar equitable_partition( $g, sub { $colors{$_[0]} } ), 3;
is scalar orbits( $g, sub { $colors{$_[0]} } ), 3;
