#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
use Graph::MoreUtils qw( equitable_partition );
use Graph::Undirected;
use List::Util qw( first uniq );
use Set::Object qw( set );

$Data::Dumper::Sortkeys = 1;

sub individualise
{
    my $vertex = pop;
    my %colors = @_;
    my $color = $colors{$vertex};
    for (keys %colors) {
        $colors{$_}++ unless $colors{$_} < $color;
    }
    $colors{$vertex}--;
    return %colors;
}

sub color_by_orbits
{
    my @orbits = @_;
    my %colors;
    for my $i (0..$#orbits) {
        for (@{$orbits[$i]}) {
            $colors{$_} = $i;
        }
    }
    return %colors;
}

sub sprint_components
{
    my( $graph ) = @_;
    my @components = $graph->connected_components;
    @components = map { [ sort @$_ ] } @components;
    @components = sort { $a->[0] <=> $b->[0] } @components;
    return '[ ' . join( ' | ', map { "@$_" } @components ) . ' ]';
}

my $automorphisms = Graph::Undirected->new( multiedged => 0 );

sub individualise_dfs
{
    my $graph = shift;
    my $level = shift;
    my @orbits = @_;

    my %colors = color_by_orbits( @orbits );

    for my $orbit (@orbits) {
        next unless @$orbit > 1;

        my @orbit = @$orbit;

        my @partitions;
        my @automorphisms;

        # Only look into non-automorphic vertices
        my $orbit_set = set( @orbit );
        for (sort @orbit) {
            next unless $automorphisms->has_vertex( $_ );
            next unless $orbit_set->has( $_ );
            $orbit_set->remove( $automorphisms->neighbours( $_ ) );
        }
        print "TRIMMED\n" unless $orbit_set->size;

        for (sort @$orbit_set) {
            # TODO: No need to individualise vertex if any of its automorphisms were already checked
            print ' ' x $level, ">>>> individualise $_\n";
            my %colors = individualise( %colors, $_ );
            my @orbits = equitable_partition( $graph, sub { $colors{$_[0]} } );
            if( @orbits == $graph->vertices ) {
                push @automorphisms, \@orbits;
                print ' ' x ($level+2), "END\n";
            } else {
                individualise_dfs( $graph, $level + 2, @orbits );
            }
        }

        for my $i (0..$#automorphisms) {
            for my $j (0..$#automorphisms) {
                next if $i == $j;
                for my $k (0..scalar( $graph->vertices ) - 1) {
                    next if $automorphisms[$i]->[$k][0] == $automorphisms[$j]->[$k][0];
                    $automorphisms->add_edge( $automorphisms[$i]->[$k][0],
                                              $automorphisms[$j]->[$k][0] );
                }
            }
        } print ' ' x $level, sprint_components( $automorphisms ), "\n" if @automorphisms;
    }
}

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

my @orbits = equitable_partition( $g1, sub { $g1_colors{$_[0]} } );
individualise_dfs( $g1, 0, @orbits );
print Dumper [ $automorphisms->connected_components ];
