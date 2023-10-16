package Graph::MoreUtils::Smoothed::Intermediate;

use strict;
use warnings;

use Scalar::Util qw( blessed );

# ABSTRACT: Generate smoothed graphs
# VERSION

sub new {
    my $class = shift;
    my $self = [ map { blessed $_ &&
                       $_->isa( Graph::MoreUtils::Smoothed::Intermediate:: ) ? @$_ : $_ } @_ ];
    return bless $self, $class;
}

sub reverse {
    my( $self ) = @_;
    @$self = reverse @$self;
    return $self;
}

1;
