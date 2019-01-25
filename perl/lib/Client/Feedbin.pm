# Client::Feedbin.pm
#   Description

package Client::Feedbin;

use feature ':5.16';

use strict;
use warnings;

use Carp qw{carp croak};
use Data::Dumper::Concise;
$Data::Dumper::Sortkeys = 1;

our $VERSION = 0.001000;

our $COUNT = 0;

use parent 'Client::REST';

# Constructors
sub init {
    my ( $self, @args ) = @_;
    return $self->Client_Feedbin__from_file(@args);
}    ##  init

sub Client_Feedbin__from_file {
    my ( $self, $config_path ) = @_;

    my $new_obj = $self->Client_REST__from_file("$config_path");
    unless ( $new_obj->{config}->{version} eq $VERSION ) {
        croak("config file version mismatch");
    }

    $new_obj->{baseurl} = "https://api.feedbin.com/v2";
    $new_obj->{config}->{base_headers}->{"Content-Type"} = "application/json";

    croak "authentication failed" unless ( $new_obj->authentication_check );

    $new_obj->cached_property_init("subscriptions");
    $new_obj->cached_property_init("taggings");

    return $new_obj;    # succeed
}    ##  init

# Public Variable Methods

# Static Methods

# Methods
sub authentication_check {
    my ($self) = @_;

    # return ( $self->get("authentication.json") );
    return ( $self->get("authentication.json")->{code} == 200 );
}    ##    authentication

sub subscriptions {
    my ( $self, $force ) = @_;

    return $self->cached_array_of_hashrefs(
        "subscriptions",
        sub {
            my ($other_self) = @_;
            return $other_self->get_json("subscriptions.json");
        },
        $force
    );
}    ##  subscriptions

sub create_subscription {
    my ( $self, $feed_url ) = @_;

    {    ## check if the sub already exists
        foreach my $some_sub ( @{ $self->subscriptions } ) {
            if (   $some_sub->{feed_url}
                && $feed_url
                &&

                $some_sub->{feed_url} =~ m/$feed_url$/i
                )
            {
                return {};
            }
        }
    }

    my $result = {};
    {    ## create the subscription
        my $result = $self->post( "subscriptions.json",
            "{ \"feed_url\": \"$feed_url\" }" );

        if ( $result->{code} == 201 || $result->{code} == 302 ) {
            $result = decode_json $result->{content};
        }
        else {
            carp( join "\n", "create_subscription: issue with post",
                $feed_url, Dumper $result);
            return { http_code => $result->{code} };
        }
    }

    push @{ $self->{cached_subscriptions} }, $result;

    return $result;
}    ##  create_subscription

sub delete_feed {
    my ( $self, $some_feed, @args ) = @_;
    ## body...
    return $self->delete( 'subscriptions/' . $some_feed->{id} . '.json' );
}    ##  delete_feed

sub rename_feed {
    my ( $self, $some_feed, $new_name ) = @_;

    my $data = "{ \"title\": \"$new_name\" }";

    my $result
        = $self->post( "subscriptions/" . $some_feed->{id} . "/update.json",
        $data );

    if ( $result->{code} == 200 ) {
        say " => $new_name";
        return decode_json $result->{content};
    }
    carp( join "\n", "rename_feed: issue with post",
        $some_feed->{id}, $new_name, Dumper $result);
    return 0;
}    ##  rename_feed

sub taggings {
    my ( $self, $force ) = @_;
    return $self->cached_array_of_hashrefs(
        "taggings",
        sub {
            my ($other_self) = @_;
            return $other_self->get_json("taggings.json");
        },
        $force
    );
}    ##  taggings

sub tag_feed {
    my ( $self, $input_feed, $tag_name ) = @_;

    {    ## check if the tagging already exists
        foreach my $some_tag ( @{ $self->taggings } ) {
            if (   $some_tag->{feed_id}
                && $input_feed->{feed_id}
                &&

                $some_tag->{feed_id} eq $input_feed->{feed_id}
                )
            {
                if ( $some_tag->{name} eq $tag_name ) {
                    return {};
                }
            }
        }
    }

    my $result = {};
    {
        my $data
            = "{ \"feed_id\": \"$input_feed->{feed_id}\", \"name\": \"$tag_name\" }";

        my $result = $self->post( "taggings.json", $data );

        if ( $result->{code} == 201 || $result->{code} == 302 ) {
            $result = decode_json $result->{content};
        }
        else {
            carp(
                join "\n",
                "tag_feed: issue with post",
                $input_feed->{feed_id},
                $tag_name, Dumper $result);
            return { http_code => $result->{code} };

        }
    }

    push @{ $self->{cached_taggings} }, $result;

    return $result;
}    ##  tag_feed

1;
