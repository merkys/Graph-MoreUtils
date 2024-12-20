#!/usr/bin/perl

use strict;
use warnings;
use Graph::Directed;
use Graph::MoreUtils qw( line );
use Test::More tests => 3;

my $g = Graph::Directed->new;
$g->add_edge( 0, 0 );
$g->add_edge( 0, 1 );
$g->add_edge( 1, 0 );
$g->add_edge( 1, 1 );

is $g->edges, 4;

my $l = line( $g );

is $l->vertices, 4;
is $l->edges, 8;
