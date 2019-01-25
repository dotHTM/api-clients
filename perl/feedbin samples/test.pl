#!/usr/bin/env perl
# test.pl
#   Description


use feature ':5.16';

use strict;
use warnings;

use Carp qw{croak};
use Data::Dumper::Concise;
$Data::Dumper::Sortkeys = 1;

use FindBin;

use lib "$FindBin::RealBin/../lib";
use FeedbinClient;

use mlc_stdlib;

my $fb = FeedbinClient->init("../../private_config.yaml");

write_to_files( Dumper $fb->{config} , "debug_object.pl" );
