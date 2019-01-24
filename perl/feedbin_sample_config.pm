# myapi_config.pm

package myapi_config;

use feature ':5.16';

use strict;
use warnings;

our $VERSION = 0.001000;

require Exporter;
our @ISA    = qw(Exporter);
our @EXPORT = qw(
    $BASE_HEADERS
);

our $BASE_HEADERS
    = { 
        "Authorization" =>
        "Basic qwertyuiop..."
    };



1;
