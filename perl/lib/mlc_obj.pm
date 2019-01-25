# mlc_obj.pm
#   Description

package mlc_obj;

use feature ':5.16';

use strict;
use warnings;

use Carp qw{croak};
use Data::Dumper::Concise;
$Data::Dumper::Sortkeys = 1;

our $VERSION = 0.001000;

our $COUNT = 0;

use lib ".";
use mlc_stdlib;

sub new {
    my $inv = shift;
    my $class = ref($inv) || $inv;
    my $self = {};
    bless($self, $class);

    $COUNT++;

    return $self;
}

sub DESTROY {
    my ($self) = @_;
    $COUNT--;
}

# Constructors

# Public Variable Methods

# Static Methods

# Object Methods

sub cached_array_of_hashrefs {
    my ( $self, $cache_key, $update_function, $force ) = @_;
    my $storage_key = "cached_" . $cache_key;
    die("update_function not CODE")
        unless ( ref($update_function) =~ m/CODE/ );
    if ( $force ? 1 : 0 || !@{ $self->{$storage_key} } ) {
        $self->{$storage_key} = &{$update_function}($self);
    }
    return $self->{$storage_key};
}    ##  cached_array_of_hashrefs

sub push_element_cached_array_of_hashrefs {
    my ( $self, $cache_key, $element ) = @_;
    my $storage_key = "cached_" . $cache_key;
    push @{ $self->{$storage_key} }, $element;
    return $self->{$storage_key};
}    ##  cached_array_of_hashrefs

sub drop_element_cached_array_of_hashrefs {
    my ( $self, $cache_key, $element ) = @_;
    my $storage_key = "cached_" . $cache_key;

    my $result = [];
    foreach my $some_element ( @{ $self->{$storage_key} } ) {
        push @{$result}, $some_element
            unless element_eq( $some_element, $element );
    }
    $self->{$storage_key} = $result;

    return $self->{$storage_key};
}    ##  cached_array_of_hashrefs



1;
