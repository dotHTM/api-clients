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

sub match_test {
    my ( $x, $y ) = @_;
    
    if( $x && $y)
    {return $x =~ m/$y/i;}
    return 0;
}

sub element_eq {
    my ( $x, $y ) = @_;
    if ( ref($x) eq "ARRAY" && ref($y) eq "ARRAY" ) {
        if ( scalar @{$x} == scalar @{$y} ) {
            for ( my $index = 0; $index < scalar @{$x}; $index++ ) {
                if ( $x->[$index] ne $y->[$index] ) { return 0 }
            }
            return 1;
        }
    }
    elsif ( ref($x) eq "HASH" && ref($y) eq "HASH" ) {
        if ( element_eq( [ keys %{$x} ], [ keys %{$y} ] ) ) {
            foreach my $index ( keys %{$x} ) {
                if ( $x->{$index} ne $y->{$index} ) { return 0 }
            }
            return 1;
        }
    }
    else {
        return $x eq $y ? 1 : 0;
    }
    return 0;
}    ##    equals_test

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
