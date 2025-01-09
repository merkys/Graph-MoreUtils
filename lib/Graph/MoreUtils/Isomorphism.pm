package Graph::MoreUtils::Isomorphism;

# ABSTRACT: Isomorphism and automorphism lookup
# VERSION

use strict;
use warnings;

use Graph::Traversal::DFS;
use List::Util qw( all uniq );
use Set::Object qw( set );

our $debug = '';

sub frequency_table
{
    my %freq;
    for (@_) { $freq{$_}++ }
    return \%freq;
}

sub cmp_frequency_tables
{
    my( $A, $B ) = @_;

    # Empty tables are the last
    return     scalar( keys %$B ) <=> scalar( keys %$A )
        unless scalar( keys %$A ) &&  scalar( keys %$B );

    return $A->{self} <=> $B->{self} unless $A->{self} == $B->{self};

    my $keys = set( keys %$A, keys %$B ) - 'self';
    for (sort { $a <=> $b } @$keys) {
        return     exists $B->{$_} <=> exists $A->{$_}
            unless exists $B->{$_} &&  exists $A->{$_};
        return     $B->{$_} <=> $A->{$_}
            unless $B->{$_} == $A->{$_};
    }

    return 0;
}

sub rename_colors
{
    my %colors = @_;
    if( all { ref $_ } values %colors ) {
        # All values are frequency tables
        my @keys = sort { cmp_frequency_tables( $colors{$a}, $colors{$b} ) } keys %colors;
        my %colors_now = ( $keys[0] => 0 );
        for (1..$#keys) {
            if( cmp_frequency_tables( $colors{$keys[$_-1]}, $colors{$keys[$_]} ) ) {
                $colors_now{$keys[$_]} = $colors_now{$keys[$_-1]} + 1;
            } else {
                $colors_now{$keys[$_]} = $colors_now{$keys[$_-1]};
            }
        }
        return %colors_now;
    } else {
        # All values are strings
        my %color_to_number;
        for (sort { $a cmp $b } uniq values %colors) {
            $color_to_number{$_} = scalar keys %color_to_number;
        }
        return map { ( $_ => $color_to_number{$colors{$_}} ) } keys %colors;
    }
}

sub canonical_order
{
    my( $graph, $color_sub ) = @_;

    my @orbits = map { set( @$_ ) } equitable_partition( $graph, $color_sub );

    my $next_root = sub {
                            my( undef, $candidates ) = @_;
                            return unless %$candidates;
                            my @successors;
                            for my $orbit (@orbits) {
                                @successors = grep { $orbit->contains( $candidates->{$_} ) } keys %$candidates;
                                last if @successors;
                            }
                            return shift @successors;
                        };

    my $operations = {
        first_root => $next_root,
        next_root => $next_root,
        next_successor => $next_root,

        pre => sub {
                        my $vertex = shift;
                        for (@orbits) {
                            $_->remove( $vertex ) && last;
                        }
                        @orbits = grep { $_->size } @orbits;
                   },
    };

    return reverse Graph::Traversal::DFS->new( $graph, %$operations )->dfs;
}

sub equitable_partition
{
    my( $graph, $color_sub ) = @_;

    $color_sub = sub { "$_[0]" } unless $color_sub;

    my %colors = rename_colors( map { ( $_ => $color_sub->( $_ ) ) }
                                    $graph->vertices );
    my @init_order = sort { $colors{$a} cmp $colors{$b} }
                     $graph->vertices;

    while( 1 ) {
        my %colors_now;
        for my $vertex ($graph->vertices) {
            $colors_now{$vertex} = frequency_table( map { $colors{$_} } $graph->neighbours( $vertex ) );
            $colors_now{$vertex}->{self} = $colors{$vertex};
        }
        %colors_now = rename_colors( %colors_now );
        last if uniq( values %colors ) == uniq( values %colors_now );
        %colors = %colors_now;
    }

    my $seen = set();
    my @orbits;
    for my $vertex (@init_order) {
        next if $seen->has( $vertex );
        push @orbits, [ grep { $colors{$_} eq $colors{$vertex} } @init_order ];
        $seen->insert( @{$orbits[-1]} );
    }
    return map { [ sort @$_ ] } @orbits;
}

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

sub individualise_dfs
{
    my $graph = shift;
    my $level = shift;
    my $automorphisms = shift;
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
        print "TRIMMED\n" if $debug && !$orbit_set->size;

        for (sort @$orbit_set) {
            print ' ' x $level, ">>>> individualise $_\n" if $debug;
            my %colors = individualise( %colors, $_ );
            my @orbits = equitable_partition( $graph, sub { $colors{$_[0]} } );
            if( @orbits == $graph->vertices ) {
                push @automorphisms, \@orbits;
                print ' ' x ($level+2), "END\n" if $debug;
            } else {
                individualise_dfs( $graph, $level + 2, $automorphisms, @orbits );
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
        } print ' ' x $level, sprint_components( $automorphisms ), "\n" if @automorphisms && $debug;
    }
}

sub orbits
{
    my( $graph, $color_sub ) = @_;
    my $automorphisms = Graph::Undirected->new( multiedged => 0 );
    individualise_dfs( $graph, 0, $automorphisms, equitable_partition( $graph, $color_sub ) );

    for ($graph->vertices) {
        next if $automorphisms->has_vertex( $_ );
        $automorphisms->add_vertex( $_ );
    }

    my @components = sort { $a->[0] <=> $b->[0] }
                     map  { [ sort @$_ ] }
                          $automorphisms->connected_components;
    return @components;
}

1;
