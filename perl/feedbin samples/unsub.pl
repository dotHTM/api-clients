#!/usr/bin/env perl
# api.pl
#   Description

use feature ':5.16';

use strict;
use warnings;

use Carp qw{croak};
use Data::Dumper::Concise;
$Data::Dumper::Sortkeys = 1;

use lib "./";
use myapi_config;

use REST::Client;
use JSON;

sub header_tuple_array {
    my ($header_hashref) = @_;
    my @result_array = ();
    foreach my $some_key ( keys %{$header_hashref} ) {
        push @result_array, [ $some_key, $header_hashref->{$some_key} ];
    }
    return @result_array;
}    ##    header_tuple_array

sub get_return {
    my ( $url, $additional_headers ) = @_;
    my $client = REST::Client->new();

    my $headers = $BASE_HEADERS;
    foreach my $somekey ( keys %{$additional_headers} ) {
        $headers->{$somekey} = $additional_headers->{$somekey};
    }
    foreach my $some_tuple ( header_tuple_array($headers) ) {
        $client->addHeader( $some_tuple->[0], $some_tuple->[1] );
    }
    $client->GET($url);
    return {
        content => $client->responseContent(),
        code    => $client->responseCode(),
        headers => { $client->responseHeaders() },
    };
}

sub authentication_check {
    croak("could not authenticate")
        unless get_return("https://api.feedbin.com/v2/authentication.json")
        ->{code} == 200 ? 1 : 0;
    return;
}    ##    authentication

authentication_check();

use lib ".";
use FEEDBIN_API;
use myapi_config;
use FileOps;

my $fb = FEEDBIN_API->init($myapi_config::BASE_HEADERS);

my $data = $fb->subscriptions();

foreach my $some_feed ( @{$data} ) {
    my $child_some_feed = $some_feed;
    {
        if ( $child_some_feed->{feed_url} =~ m/twitter\.com/gmi ) {
            $fb->delete_feed($child_some_feed) && say "x ".$child_some_feed->{title};
        }
    }
}

