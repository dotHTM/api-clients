#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;

use Carp qw{croak};
use Data::Dumper::Concise;
$Data::Dumper::Sortkeys = 1;

use FindBin;
use Time::Piece;

use lib "$FindBin::RealBin/../lib";
use Client::Feedbin;
use CachedProperty;

use mlc_stdlib;

# my $fb = Client::Feedbin->init("../../private_config.yaml");

# write_file( "debug_object.pl", Dumper $fb );

my $thing = CachedProperty->init( "thing", ["id"] );
$thing->set(
    [   { id => 1, val => "v1" },
        { id => 2, val => "v2" },
        { id => 3, val => "v3" },
        { id => 4, val => "v4" },
    ]
);





write_file( "debug_object.pl",
    '#' . localtime->datetime . "\n" . Dumper $thing );




