#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
use Graph::MoreUtils qw( orbits );
use Graph::Undirected;
use List::Util qw( any first );
use Set::Object qw( set );

$Graph::MoreUtils::Isomorphism::debug = 1;

local $\ = "\n";

sub refine
{
    my $graph = shift;
    my $vertex = shift;
    my @cells = @_;
    print "cells before individualisation: @cells";

    # Move the individualized vertex to a cell of its own
    my $cell = first { $cells[$_]->has( $vertex ) } 0..$#cells;
    $cells[$cell] -= $vertex;
    @cells = ( @cells[0..$cell-1], set( $vertex ), @cells[$cell..$#cells] );
    print "cells after  individualisation: @cells";

    my @cells_to_check = ( $cells[$cell] );
    while( @cells_to_check ) {
        my $cell = shift @cells_to_check; print "check $cell";

        my @cells_now;
        for my  $affected_cell (@cells) {
            if( $affected_cell == $cell || $affected_cell->size == 1 ) {
                push @cells_now, $affected_cell;
                next;
            }

            my @neighbours_per_vertex;
            for my $vertex (@$affected_cell) {
                my $neighbours = (set( $graph->neighbours( $vertex ) ) * $cell)->size;
                print $vertex, ' ', $neighbours;
                $neighbours_per_vertex[$neighbours] = [] unless $neighbours_per_vertex[$neighbours];
                push @{$neighbours_per_vertex[$neighbours]}, $vertex;
            }

            my @new_cells = map { set( @$_ ) } reverse grep { $_ } @neighbours_per_vertex;
            push @cells_now, @new_cells;
            push @cells_to_check, @new_cells[1..$#new_cells] if @new_cells > 1;
        }
        @cells = @cells_now;
        print "after checking: @cells";
        print "new cells to check: @cells_to_check";
    }

    return @cells;
}

my $g = Graph::Undirected->new;
$g->add_cycle( 0, 1, 2, 5, 8, 7, 6, 3 );
$g->add_cycle( 1, 3, 7, 5 );
$g->add_path( 1, 4, 7 );
$g->add_path( 3, 4, 5 );

# print Dumper [ orbits( $g, sub { '' } ) ];

#~ my @cells = refine( $g, '5', set( '1', '3', '5', '7' ), set( '0', '2', '6', '8' ), set( '4' ) );
#~ refine( $g, '7', @cells );
#~ refine( $g, '1', @cells );

$g = Graph::Undirected->new;
$g->add_cycle( 1, 4, 9, 5, 2, 6, 10, 3 );
$g->add_path( 3, 7, 5 );
$g->add_path( 4, 8, 6 );
$g->add_edge( 7, 9 );
$g->add_edge( 8, 10 );

#~ my @cells = refine( $g, '3', set( '1', '2' ), set( '3', '4', '5', '6' ), set( '7', '8', '9', '10' ) );
#~ refine( $g, '5', @cells );

$g = Graph::Undirected->new;
$g->add_cycle( 0..4 );
$g->add_cycle( 5, 7, 9, 6, 8 );
for (0..4) {
    $g->add_edge( $_, 5 + $_ );
}

my @cells = refine( $g, '0', set( '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' ) );
@cells = refine( $g, '1', @cells );
refine( $g, '3', @cells );
refine( $g, '8', @cells );
