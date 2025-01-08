package Graph::MoreUtils::Isomorphism;

# ABSTRACT: Isomorphism and automorphism lookup
# VERSION

use strict;
use warnings;

use Graph::Traversal::DFS;
use List::Util qw( all uniq );
use Set::Object qw( set );

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

    my @orbits = map { set( @$_ ) } orbits( $graph, $color_sub );

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

sub orbits
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

1;
