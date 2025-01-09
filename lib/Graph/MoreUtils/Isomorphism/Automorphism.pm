package Graph::MoreUtils::Isomorphism::Automorphism;

# ABSTRACT: Object for automorphism tracking
# VERSION

use strict;
use warnings;

use Graph::Undirected;
use Set::Object qw( set );

sub new
{
    my( $class, @items ) = @_;
    my $graph = Graph::Undirected->new( refvertexed => 1 );
    $graph->add_vertices( @items );
    return bless { graph => $graph, orbits => [] }, $class;
}

sub add_partition
{
    my $self = shift;
    my @partition = @_;
    for my $i (0..$#partition) {
        push @{$self->{orbits}}, {} unless @{$self->{orbits}} > $i;
        $self->{graph}->add_edge( $self->{orbits}[$i], $partition[$i] );
    }
}

sub automorphisms
{
    my( $self, $item ) = @_;
    my @automorphisms;
    return @automorphisms unless $self->{graph}->has_vertex( $item );

    @automorphisms = grep { $_ != $item }
                     map  { $self->{graph}->neighbours( $_ ) }
                          $self->{graph}->neighbours( $item );
    return @automorphisms;
}

sub orbits
{
    my( $self ) = @_;
    my $orbits = set( @{$self->{orbits}} );
    my @components = sort { $a->[0] <=> $b->[0] }
                     map  { [ sort grep { !$orbits->has( $_ ) } @$_ ] }
                     $self->{graph}->connected_components;
    return @components;
}

1;
