#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
use Graph::MoreUtils qw( orbits );
use Graph::Undirected;

my $g = Graph::Undirected->new;
$g->add_cycle( 1..8 );
$g->add_cycle( 3, 7, 4, 8 );

$Graph::MoreUtils::Isomorphism::debug = 1;

print Dumper [ orbits( $g, sub { '' } ) ];
