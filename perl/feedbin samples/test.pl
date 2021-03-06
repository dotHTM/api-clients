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

my $buffer ;



if (1) {
    my $fb = Client::Feedbin->init("../../private_config.yaml");
    write_file( "debug_object_fb.pl", Dumper $fb );
}

if (0) {
    my $thing = CachedProperty->init( "thing", ["id"] );
    $thing->set(
                [   { id => 1, val => "v1" },
                { id => 2, val => "v2" },
                { id => 3, val => "v1" },
                { id => 4, val => "v4" },
                ]
                );
    $thing->append( { id => 5, val => "a5" } );
    $buffer.="\n".  "Dropped: ". Dumper $thing->drop( { id => 3, val => "v1" }, );
    write_file( "debug_object_hash.pl",
               '#' . localtime->datetime . "\n" . Dumper $thing );
}

if (0) {
    my $thing = CachedProperty->init( "thing", ["id"], ["val"] );
    $thing->set(
                [   { id => 1, val => "v1" },
                { id => 2, val => "v2" },
                { id => 3, val => "v1" },
                { id => 4, val => "v4" },
                ]
                );
    $thing->append( { id => 5, val => "a5" } );
    $buffer.="\n".   "Dropped: " . Dumper $thing->drop( { id => 3, val => "v1" }, );
    write_file( "debug_object_hash_2.pl",
               '#' . localtime->datetime . "\n" . Dumper $thing );
}

if (0) {
    my $thing = CachedProperty->init("thing", ["id"]);
    $thing->set( [ ["1"],
                ["2"],
                ["3", "4"], ] );
    $thing->append(["5","6"]);
    $buffer.="\n".   "Dropped: " . Dumper $thing->drop(["3","4"]);
    write_file( "debug_object_array.pl",
               '#' . localtime->datetime . "\n" . Dumper $thing );
}

if (0) {
    my $thing = CachedProperty->init("thing", ["id"]);
    $thing->set( [ "1", "2", "3", "4", ] );
    $thing->append("5");
    $buffer.="\n".   "Dropped: " . Dumper $thing->drop("3");
    write_file( "debug_object_scalar.pl",
               '#' . localtime->datetime . "\n" . Dumper $thing );
}

# write_file( "debug_object_dropped.pl", $buffer);
