#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;

use Carp qw{croak};
use Data::Dumper::Concise;
$Data::Dumper::Sortkeys = 1;

use FindBin;

use lib "$FindBin::RealBin/../lib";
use Client::Feedbin;

use mlc_stdlib;

my $fb = Client::Feedbin->init("../../private_config.yaml");

write_file( "debug_object.pl", Dumper $fb->{config} );


