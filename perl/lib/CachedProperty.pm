# CachedProperty.pm
#   Description

package CachedProperty;

use feature ':5.16';

use strict;
use warnings;

use Carp qw{carp croak};
use Data::Dumper::Concise;
$Data::Dumper::Sortkeys = 1;

our $VERSION = 1.0;

our $COUNT = 0;

use mlc_stdlib;

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
    my ( $self, $name, $indexed_keys ) = @_;
    my $new_obj = $self->new();
    $new_obj->{storage_name}  = $name;
    $new_obj->{storage_array} = [];
    $new_obj->{indexed_keys}  = $indexed_keys;
    $new_obj->build_index();

    return $new_obj;    # succeed
}    ##  init

# Public Variable Methods
# Methods

sub name {
    my ($self) = @_;
    return $self->{storage_name};    # succeed
}    ##  name

sub value {
    my ($self) = @_;
    return $self->{storage_array};
}    ##  value

sub get {
    my ($self) = @_;
    return $self->value;
}    ##  get

sub set {
    my ( $self, $new_value ) = @_;
    $self->{storage_array} = $new_value
        || croak( "CachedProperty: "
            . $self->{storage_name}
            . ": Could not set value" );
    # if ( $self->{indexed_keys} && @{ $self->{indexed_keys} } ) {
    $self->build_index();
    # }
    return $self->{storage_array};
}    ##  cached_array_of_hashrefs

sub append {
    my ( $self, $cache_key, $element ) = @_;
    push @{ $self->{storage_array} }, $element
        || croak( "CachedProperty: "
            . $self->{storage_name}
            . ": Could not update element" );
    return $self->{storage_array};
}    ##  cached_array_of_hashrefs

sub drop {
    my ( $self, $cache_key, $element ) = @_;
    my @result = ();
    foreach my $this_element ( @{ $self->{storage_array} } ) {
        CORE::push @result, $this_element
            unless element_eq( $this_element, $element );
    }
    $self->{storage_array} = \@result
        || croak( "CachedProperty: "
            . $self->{storage_name}
            . ": Could not drop element" );
    return $self->{storage_array};
}    ##  cached_array_of_hashrefs

################################################################
## indexing
#

sub scalar_index {
    my ( $self, $key ) = @_;
    $self->{index} = {};
    foreach my $x ( @{ $self->{storage_array} } ) {
        $self->{index}->{$x} = 1;
    }
    return 1;    # succeed
}    ##  build_index_on

sub reset_index {
    my ($self) = @_;
    $self->{index} = {};
    foreach my $this_index_key ( @{ $self->{indexed_keys} } ) {
        $self->{index}->{$this_index_key} = {};
    }
    return 1;
}

sub build_index {
    my ($self) = @_;
    $self->reset_index();
    foreach my $this_element ( @{ $self->{storage_array} } ) {
        $self->append_index($this_element);
    }
    return 1;    # succeed
}    ##  build_index

sub append_index {
    my ( $self, $this_element ) = @_;
    

    unless ( ref($this_element) =~ m/HASH/gi ) {
        $self->{index}->{$this_element} = 1;
        return 1;
    }
    
foreach my $this_key (@{ $self->{indexed_keys} }) {
    if ($self->{index}->{$this_key}->    {
            $this_element->{$this_key}
            }){
        carp("index already has element at '$this_key'. Cannot guarantee one-to-one mapping on non-unique indices.");
    }
}

    foreach my $this_index_key ( @{ $self->{indexed_keys} } ) {
        my $key_value;
        unless ( $key_value = $this_element->{$this_index_key} ) {
            carp("element has undef at key: $this_index_key");
            carp( Dumper $this_element );
            next;
        }
        $self->{index}->{$this_index_key}->{$key_value} = $this_element;
    }
    return 1;    # succeed
}    ##  append_index

1;
