#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
use Graph::MoreUtils qw( orbits );
use Graph::Undirected;
use List::Util qw( any first );
use Set::Object qw( set );

my $g = Graph::Undirected->new;
$g->add_cycle( 0, 1, 2, 5, 8, 7, 6, 3 );
$g->add_cycle( 1, 3, 7, 5 );
$g->add_path( 1, 4, 7 );
$g->add_path( 3, 4, 5 );

$Graph::MoreUtils::Isomorphism::debug = 1;

local $\ = "\n";

sub refine
{
    my $graph = shift;
    my $vertex = shift;
    my @cells = @_;

    # Move the individualized vertex to a cell of its own
    my $cell = first { $cells[$_]->has( $vertex ) } 0..$#cells;
    $cells[$cell] -= $vertex;
    @cells = ( @cells[0..$cell-1], set( $vertex ), @cells[$cell..$#cells] );
    print "cells after individualisation: @cells";

    my $affected_vertices = set( map { $graph->neighbours( $_ ) } $cells[$cell+1]->members ) -
                            set( map { $_->members } @cells[0..$cell+1] );
    my @affected_cells = grep { $_->size > 1 } grep { !$_->is_disjoint( $affected_vertices ) } @cells;
    my @cells_now = @cells[0..$cell+1];

    for my  $affected_cell (@cells[$cell+2..$#cells]) {
        if( $affected_cell->size == 1 ) {
            push @cells_now, $affected_cell;
            next;
        }

        my @neighbours_per_vertex;
        for my $vertex (@$affected_cell) {
            my $neighbours = (set( $graph->neighbours( $vertex ) ) * $cells[$cell+1])->size;
            $neighbours_per_vertex[$neighbours] = [] unless $neighbours_per_vertex[$neighbours];
            push @{$neighbours_per_vertex[$neighbours]}, $vertex;
        }

        push @cells_now, map { set( @$_ ) } reverse grep { $_ } @neighbours_per_vertex;
    }

    print "@cells_now";
}

# print Dumper [ orbits( $g, sub { '' } ) ];

refine( $g, '5', set( '1', '3', '5', '7' ), set( '0', '2', '6', '8' ), set( '4' ) );
