#!/usr/bin/perl

use strict;
use warnings;
use Graph::MoreUtils qw( line );
use Graph::Undirected;
use Test::More tests => 3;

my $g = Graph::Undirected->new;
$g->add_edges( [ 'A', 'B' ], [ 'A', 'C' ], [ 'A', 'D' ] );

my $l = line( $g );

is( $l->vertices, 3 );
is( $l->edges, 3 );
is( (grep { $l->degree( $_ ) == 2 } $l->vertices), 3 );
