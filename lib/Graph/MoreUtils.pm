package Graph::MoreUtils;

# ABSTRACT: Utilities for graphs
# VERSION

=head1 NAME

Graph::MoreUtils - utilities for graphs

=head1 SYNOPSIS

    use Graph::MoreUtils qw( SSSR line smooth );
    use Graph::Undirected;

    my $G = Graph::Undirected->new;

    # Greate graph here

    # Get line graph for $G:
    my $L = line( $G );

=cut

use strict;
use warnings;

use parent Exporter::;

use Graph::MoreUtils::Line;
use Graph::MoreUtils::SSSR;
use Graph::MoreUtils::Smoothed;

our @EXPORT_OK = qw(
    SSSR
    line
    smooth
);

sub SSSR { &Graph::MoreUtils::SSSR::SSSR }

=head2 C<line( $graph )>

Generates line graphs for L<Graph::Undirected> objects.
Line graph is constructed nondestructively and returned from the call.
Both simple and multiedged graphs are supported.

Call accepts additional options hash.
Currently only one option is supported, C<loop_end_vertices>, which treats the input graph as having self-loops on pendant vertices, that is, increasing the degrees of vertices having degrees of 1.
Thus they are not "lost" during line graph construction.
In the resulting line graph these self-loops are represented as instances of L<Graph::MoreUtils::Line::SelfLoopVertex>.

=cut

sub line { &Graph::MoreUtils::Line::line }
sub smooth { &Graph::MoreUtils::Smoothed::smooth }

=head1 SEE ALSO

perl(1)

=head1 AUTHORS

Andrius Merkys, E<lt>merkys@cpan.orgE<gt>

=cut

1;
