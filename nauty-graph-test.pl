#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
use Graph::MoreUtils qw( orbits );
use Graph::Undirected;

my $g = Graph::Undirected->new;
$g->add_cycle( 0, 1, 2, 5, 8, 7, 6, 3 );
$g->add_cycle( 1, 3, 7, 5 );
$g->add_path( 1, 4, 7 );
$g->add_path( 3, 4, 5 );

$Graph::MoreUtils::Isomorphism::debug = 1;

print Dumper [ orbits( $g, sub { '' } ) ];
