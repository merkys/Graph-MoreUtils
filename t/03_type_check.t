#!/usr/bin/perl

use strict;
use warnings;
use Graph;
use Graph::MoreUtils::Line;
use Test::More tests => 1;

my $error;

eval {
    my $g = Graph->new;
    my $l = Graph::MoreUtils::Line->new( $g );
};
if( $@ ) {
    $@ =~ s/\n$//;
    $error = $@;
}

is( $error, 'only Graph::Undirected and its derivatives accepted' );
