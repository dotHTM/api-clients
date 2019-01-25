# mlc_obj.pm
#   Description

package Client::REST;

use feature ':5.16';

use strict;
use warnings;

use Carp qw{croak};
use Data::Dumper::Concise;
$Data::Dumper::Sortkeys = 1;

our $VERSION = 0.001000;

our $COUNT = 0;

use REST::Client;
use JSON;
use YAML::Tiny;

use mlc_stdlib;
use CachedProperty;

# Constructors

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

sub init {
    my ( $self, @args ) = @_ ;
    return $self->Client_REST__from_file(@args);
}   ##  init

sub Client_REST__from_file {
    my ( $self, $config_path ) = @_;

    my $new_obj = $self->new();
    $new_obj->{config} = YAML::Tiny->read($config_path)->[0];
    
    # $new_obj->{config}->{base_headers}
    # $new_obj->{baseurl}                        = "https://api.feedbin.com/v2";
    # $new_obj->{config}->{base_headers}                   = $headers;
    # $new_obj->{config}->{base_headers}->{"Content-Type"} = "application/json";
    
    

    # unless ( $new_obj->authentication_check ) {
    #     carp "authentication failed";
    #     exit 1;
    # }

    # $new_obj->subscriptions(1);
    # $new_obj->taggings(1);

    return $new_obj;    # succeed
}    ##  init

# Public Variable Methods

# Static Methods

sub cached_property_init {
    my ( $self, $name ) = @_;
    $self->{$name} = CachedProperty->init($name);
    return $self->{$name};
}    ##    cached_property_init


# Object Methods

################################################################
## REST Methods


sub hashref_to_tuple_array {
    my ($input_hashref) = @_;
    my @result_array = ();
    foreach my $some_key ( keys %{$input_hashref} ) {
        push @result_array, [ $some_key, $input_hashref->{$some_key} ];
    }
    return @result_array;
}    ##    hashref_to_tuple_array

sub get {
    my ( $self, $tail_url, $additional_headers ) = @_;

    my $client = REST::Client->new();

    my $headers = $self->{config}->{feedbin}->{options}->{base_headers};
    foreach my $somekey ( keys %{$additional_headers} ) {
        $headers->{$somekey} = $additional_headers->{$somekey};
    }
    foreach my $some_tuple ( hashref_to_tuple_array($headers) ) {
        $client->addHeader( $some_tuple->[0], $some_tuple->[1] );
    }
    $client->GET( $self->{baseurl} . "/" . $tail_url );

    return {
        content => $client->responseContent(),
        code    => $client->responseCode(),
    };    # succeed
}    ##  get

sub get_content {
    my ( $self, @args ) = @_;
    my $result = $self->get(@args);

    return $result->{content};    # succeed
}    ##  get_content

sub get_json {
    my ( $self, @args ) = @_;
    return decode_json $self->get_content(@args);    # succeed
}    ##  get_json

sub post {
    my ( $self, $tail_url, $data, $additional_headers ) = @_;

    my $client = REST::Client->new();

    my $headers = $self->{config}->{base_headers};
    foreach my $somekey ( keys %{$additional_headers} ) {
        $headers->{$somekey} = $additional_headers->{$somekey};
    }
    foreach my $some_tuple ( hashref_to_tuple_array($headers) ) {
        $client->addHeader( $some_tuple->[0], $some_tuple->[1] );
    }

    my $assembled_url = $self->{baseurl} . "/" . $tail_url;

    # say "assembled_url: $assembled_url";
    # say "data:          $data";
    $client->POST( $assembled_url, $data );

    return {
        content => $client->responseContent(),
        code    => $client->responseCode(),
    };    # succeed
}    ##  post


sub post_content {
    my ( $self, @args ) = @_;
    my $result = $self->post(@args);

    return $result->{content};    # succeed
}    ##  post_content

sub post_json {
    my ( $self, @args ) = @_;
    if ( my $result = $self->post_content(@args) ) {
        return decode_json $result;    # succeed
    }
    return;
}    ##  post_json

sub delete {
    my ( $self, $tail_url, $additional_headers ) = @_;

    my $client = REST::Client->new();

    my $headers = $self->{config}->{base_headers};
    foreach my $somekey ( keys %{$additional_headers} ) {
        $headers->{$somekey} = $additional_headers->{$somekey};
    }
    foreach my $some_tuple ( hashref_to_tuple_array($headers) ) {
        $client->addHeader( $some_tuple->[0], $some_tuple->[1] );
    }
    $client->DELETE( $self->{baseurl} . "/" . $tail_url );

    return {
        content => $client->responseContent(),
        code    => $client->responseCode(),
    };    # succeed
}    ##  delete



1;
