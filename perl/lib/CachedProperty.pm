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
    my ( $self, $name, $uniq_indexed_keys, $ordinary_indexed_keys ) = @_;

    $uniq_indexed_keys     = $uniq_indexed_keys     || [];
    $ordinary_indexed_keys = $ordinary_indexed_keys || [];

    foreach my $x ( $uniq_indexed_keys, $ordinary_indexed_keys ) {

        unless ( ref($x) =~ m/ARRAY/ ) {
            croak( join "\n",
                "$self initialized with non-hashref for index category.",
                $x, Dumper $x );
        }
    }

    my $new_obj = $self->new();
    $new_obj->{storage_name}          = $name;
    $new_obj->{storage_array}         = [];
    $new_obj->{uniq_indexed_keys}     = $uniq_indexed_keys;
    $new_obj->{ordinary_indexed_keys} = $ordinary_indexed_keys;
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

    # if ( $self->{uniq_indexed_keys} && @{ $self->{uniq_indexed_keys} } ) {
    $self->build_index();

    # }
    return $self->{storage_array};
}    ##  cached_array_of_hashrefs

sub append {
    my ( $self, $new_element ) = @_;
    push @{ $self->{storage_array} }, $new_element
        || croak( "CachedProperty: "
            . $self->{storage_name}
            . ": Could not update element" );
    $self->append_index($new_element);
    return $self->{storage_array};
}    ##  cached_array_of_hashrefs

sub drop {
    my ( $self, $dropped_element ) = @_;
    my @result = ();

    # foreach my $this_element ( @{ $self->{storage_array} } ) {
    #     CORE::push @result, $this_element
    #         unless element_eq( $this_element, $dropped_element );
    # }

    for ( my $i = 0; $i < scalar @{ $self->{storage_array} }; $i++ ) {
        if ( element_eq( $self->{storage_array}->[$i], $dropped_element ) ) {
            delete $self->{storage_array}->[$i];
            last;
        }
    }
    
    $self->drop_index($dropped_element);

    # $self->{storage_array} = \@result
    #     || croak( "CachedProperty: "
    #         . $self->{storage_name}
    #         . ": Could not drop element" );
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
    $self->{index}     = {};
    $self->{ord_index} = {};
    foreach my $this_index ( @{ $self->{uniq_indexed_keys} } ) {
        $self->{index}->{$this_index} = {};
    }
    foreach my $this_index ( @{ $self->{ordinary_indexed_keys} } ) {
        $self->{ord_index}->{$this_index} = {};
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

    # foreach my $this_key ( @{ $self->{uniq_indexed_keys} } ) {

    # }
    foreach my $this_index ( @{ $self->{uniq_indexed_keys} } ) {
        my $index_key;
        unless ( $index_key = $this_element->{$this_index} ) {
            carp("element has undef at key: $this_index");
            carp( Dumper $this_element );
            next;
        }
        if ( $self->{index}->{$this_index}->{$index_key} ) {
            carp(
                "index already has element at '$this_index'. Cannot guarantee one-to-one mapping on non-unique indices."
            );
        }
        $self->{index}->{$this_index}->{$index_key} = $this_element;
    }

    foreach my $this_index ( @{ $self->{ordinary_indexed_keys} } ) {
        my $index_key;
        unless ( $index_key = $this_element->{$this_index} ) {
            carp("element has undef value at key: $this_index");
            carp( Dumper $this_element );
            next;
        }
        push @{ $self->{ord_index}->{$this_index}->{$index_key} },
            $this_element;
    }

    return 1;    # succeed
}    ##  append_index

sub drop_index {
    my ( $self, $dropped_element ) = @_;
    
    say "looking for". Dumper $dropped_element; 

    foreach my $this_index ( @{ $self->{uniq_indexed_keys} } ) {
        my $index_key = $dropped_element->{$this_index};
        delete $self->{index}->{$this_index}->{$index_key};
    }
    foreach my $this_index ( @{ $self->{ordinary_indexed_keys} } ) {
        my $index_key = $dropped_element->{$this_index};

        for ( my $i = 0; $i < scalar @{ $self->{ord_index}->{$this_index}->{$index_key} }; $i++ ) {
            if ( element_eq( $self->{ord_index}->{$this_index}->{$index_key}->[$i], $dropped_element ) )
            {
                delete $self->{ord_index}->{$this_index}->{$index_key}->[$i];
                last;
            }
        }

    }

    return 1;    # succeed
}    ##  drop_index

1;
