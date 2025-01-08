#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
use Graph::MoreUtils qw( orbits );
use Graph::Undirected;
use List::Util qw( first uniq );

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

sub colors_to_orbits
{
    my %colors = @_;
    my @orbits;
    for (sort keys %colors) {
        push @{$orbits[$colors{$_}]}, $_;
    }
    return @orbits;
}

sub individualise_until_discrete
{
    my $graph = shift;
    my %colors = @_;

    return %colors if uniq( values %colors ) == $graph->vertices;

    my $vertex;
    for my $color (sort uniq values %colors) {
        my @orbit = grep { $colors{$_} == $color } sort keys %colors;
        next unless @orbit > 1;

        $vertex = shift @orbit;
    }

    %colors = individualise( %colors, $vertex );
    my @orbits = orbits( $graph, sub { $colors{$_[0]} } );

    return individualise_until_discrete( $graph, color_by_orbits( @orbits ) );
}

sub individualise_dfs
{
    my $graph = shift;
    my %colors = @_;

    return { %colors } if uniq( values %colors ) == $graph->vertices;

    my @orbit;
    for my $color (sort uniq values %colors) {
        @orbit = grep { $colors{$_} == $color } sort keys %colors;
        last if @orbit > 1;
    }

    my @partitions;
    for (@orbit) {
        push @partitions, individualise_dfs( $graph, individualise( %colors, $_ ) );
    }
    return @partitions;
}

my $g = Graph::Undirected->new;
$g->add_cycle( '01', '04', '09', '05', '02', '06', '10', '03' );
$g->add_path( '03', '07', '05' );
$g->add_path( '04', '08', '06' );
$g->add_edge( '07', '09' );
$g->add_edge( '08', '10' );

my %colors;
for ($g->vertices) {
    $colors{$_} = 0 + ($_ > 2);
}

my @orbits = orbits( $g, sub { $colors{$_[0]} } );
%colors = color_by_orbits( @orbits );

print STDERR scalar individualise_dfs( $g, %colors );
