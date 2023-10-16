package Graph::Line::SelfLoopVertex;

use strict;
use warnings;

# ABSTRACT: Marker for artificial self-loops
# VERSION

sub new
{
    my( $class ) = @_;
    return bless {}, $class;
}

1;

__END__

=pod

=head1 NAME

Graph::Line::SelfLoopVertex - marker for artificial self-loops

=head1 DESCRIPTION

With C<loop_end_vertices> option L<Graph::Line|Graph::Line> adds
self-loops on pendant vertices thus preserving them from getting "lost".
Instances of Graph::Line::SelfLoopVertex are used to represent the
artificial self-loops in the resulting line graphs.

=head1 SEE ALSO

perl(1)

=head1 AUTHORS

Andrius Merkys, E<lt>merkys@cpan.orgE<gt>

=cut
