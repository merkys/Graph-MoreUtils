package Graph::MoreUtils;

# ABSTRACT: Utilities for graphs
# VERSION

use strict;
use warnings;

use parent Exporter::;

use Graph::MoreUtils::SSSR;

our @EXPORT_OK = qw(
    SSSR
);

sub SSSR { &Graph::MoreUtils::SSSR::SSSR }

1;
