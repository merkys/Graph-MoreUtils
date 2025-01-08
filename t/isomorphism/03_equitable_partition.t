#!/usr/bin/perl

use strict;
use warnings;

use Graph::MoreUtils qw( equitable_partitions );
use Graph::Undirected;
use Test::More;

plan skip_all => "Skip \$ENV{EXTENDED_TESTING} is not set\n" unless $ENV{EXTENDED_TESTING};

eval 'use Graph::Maker';
plan skip_all => 'no Graph::Maker' if $@;
eval 'use Graph::Maker::Random';
plan skip_all => 'no Graph::Maker::Random' if $@;
eval 'use Graph::Nauty';
plan skip_all => 'no Graph::Nauty' if $@;

my $N = 100;
my $srand = srand;

plan tests => $N;

for (1..$N) {
    my $g = Graph::Maker->new( 'random', N => 100, PR => 0.75, undirected => 1 );

    my $GN_orbits    = represent_orbits( Graph::Nauty::orbits( $g, sub { '' } ) );
    my $local_orbits = represent_orbits( equitable_partitions( $g, sub { '' } ) );
    is $GN_orbits, $local_orbits, "srand $srand, test $_";
}

sub represent_orbits { join( ',', sort map { scalar @$_ } @_ ), "\n" }
