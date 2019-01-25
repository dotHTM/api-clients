# CachedProperty.pm
#   Description

package CachedProperty;

use feature ':5.16';

use strict;
use warnings;

use Carp qw{croak};
use Data::Dumper::Concise;
$Data::Dumper::Sortkeys = 1;

our $VERSION = 1.0;

our $COUNT = 0;

sub new {
    my $inv   = shift;
    my $class = ref($inv) || $inv;
    my $self  = {};
    bless( $self, $class );

    $COUNT++;

    return $self;
}

sub DESTROY {
    my ($self) = @_;
    $COUNT--;
}

# Constructors

sub init {
    my ( $self, $name ) = @_;
    my $new_obj = $self->new();
    $new_obj->{name} = $name;
    return 1;    # succeed
}    ##  init

# Public Variable Methods
# Methods

sub value {
    my ($self) = @_;
    return $self->{value};
}    ##  value

sub get {
    my ($self) = @_;
    return $self->value;
}    ##  get

sub set {
    my ( $self, $new_value ) = @_;
    $self->{value} = $new_value
        || croak( $self->{name} . ": Could not set value" );
    return $self->{value};
}    ##  cached_array_of_hashrefs

sub push {
    my ( $self, $cache_key, $element ) = @_;
    push @{ $self->{value} }, $element
        || croak( $self->{name} . ": Could not update element" );
    return $self->{value};
}    ##  cached_array_of_hashrefs

sub drop {
    my ( $self, $cache_key, $element ) = @_;
    my @result = ();
    foreach my $some_element ( @{ $self->{value} } ) {
        CORE::push @result, $some_element
            unless element_eq( $some_element, $element );
    }
    $self->{value} = \@result
        || croak( $self->{name} . ": Could not drop element" );
    return $self->{value};
}    ##  cached_array_of_hashrefs

1;
