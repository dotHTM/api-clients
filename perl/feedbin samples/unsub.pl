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



use lib ".";
use FeedbinClient;
use myapi_config;
use FileOps;

my $fb = FeedbinClient->init($myapi_config::BASE_HEADERS);

my $data = $fb->subscriptions();

foreach my $some_feed ( @{$data} ) {
    my $child_some_feed = $some_feed;
    {
        if ( $child_some_feed->{feed_url} =~ m/twitter\.com/gmi ) {
            $fb->delete_feed($child_some_feed) && say "x ".$child_some_feed->{title};
        }
    }
}

