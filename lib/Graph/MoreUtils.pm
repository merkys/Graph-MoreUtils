package Graph::MoreUtils;

# ABSTRACT: Utilities for graphs
# VERSION

use strict;
use warnings;

use parent Exporter::;

use Graph::MoreUtils::SSSR;
use Graph::MoreUtils::Smoothed;

our @EXPORT_OK = qw(
    SSSR
    smooth
);

sub SSSR { &Graph::MoreUtils::SSSR::SSSR }
sub smooth { &Graph::MoreUtils::Smoothed::smooth }

1;
