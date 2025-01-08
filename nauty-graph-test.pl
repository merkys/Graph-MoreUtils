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
        my %colors = individualise( %colors, $_ );
        my @orbits = orbits( $graph, sub { $colors{$_[0]} } );
        push @partitions, individualise_dfs( $graph, color_by_orbits( @orbits ) );
    }
    return @partitions;
}

my $g = Graph::Undirected->new;
#~ $g->add_cycle( '01', '04', '09', '05', '02', '06', '10', '03' );
#~ $g->add_path( '03', '07', '05' );
#~ $g->add_path( '04', '08', '06' );
#~ $g->add_edge( '07', '09' );
#~ $g->add_edge( '08', '10' );
$g->add_cycle( 0..4 );
$g->add_cycle( 5, 7, 9, 6, 8 );
for (0..4) {
    $g->add_edge( $_, 5 + $_ );
}

my %colors;
for ($g->vertices) {
    $colors{$_} = 0; # + ($_ > 2);
}

my @orbits = orbits( $g, sub { $colors{$_[0]} } );
%colors = color_by_orbits( @orbits );

my @partitions = individualise_dfs( $g, %colors );
my %freq;
for my $partition (@partitions) {
    for my $vertex (keys %$partition) {
        $freq{$vertex}->{$partition->{$vertex}}++;
    }
}
print scalar @partitions, "\n";
# print STDERR Dumper \%freq;
