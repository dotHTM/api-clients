#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;

use Carp qw{croak};
use Data::Dumper::Concise;
$Data::Dumper::Sortkeys = 1;

use lib ".";
use FEEDBIN_API;
use feedbin_config;
use mlc_stdlib;

sub read_twitter_data {
    my ( $input, $parameters, @args ) = @_;
    foreach my $line ( split "\n", read_files("categorized.txt") ) {
        my $data = {};
        if ( $line =~ m/^(\S+?)\s+(\S.*)/i ) {
            my ( $screen_name, $tag_string ) = ( $1, $2 );
            if ($tag_string) {
                $data->{$screen_name} = [ split " ", $tag_string ];
            }
            else { $data->{$screen_name} = [] }
        }
    }
    return $data;
}    ##    read_twitter_data

sub quick_tag {
    my ( $fb, $level, $some_tag ) = @_;
    $fb->tag_feed(
        $twitter_feed,
        (   join "",            $tag_prefix_twitter, $level,
            $tag_delim_twitter, $some_tag
        )
    );
}    ##    tag

my $tag_prefix_twitter = "x.8.";
my $tag_delim_twitter  = " 🦆 ";

my $fb           = FEEDBIN_API->init($feedbin_config::BASE_HEADERS);
my $tagging_data = read_twitter_data($SOME_PATH_FROM_COMMAND_LINE);
foreach my $screen_name ( keys %{$tagging_data} ) {
    my $twitter_url  = "twitter.com/$screen_name";
    my $twitter_feed = $fb->create_subscription($twitter_url);
    quick_tag( $fb, "0", "Bankrupt" );

    unless ( scalar @{ $tagging_data->{$screen_name} } ) {
        quick_tag( $fb, "9", "import" );
    }

    foreach my $some_tag ( @{ $tagging_data->{$screen_name} } ) {
        quick_tag( $fb, "5", $some_tag );
        if (( $some_tag =~ m/nsfw/ || $screen_name =~ m/nsfw/ )

# && !( $some_feed->{title} =~ m/ __nsfw/ ) ## should be handled by the object
            )
        {    ## mark things so they can be easily muted/deleted inside Feedbin
            my $renamed_feed = $fb->rename_feed( $some_feed,
                "@" . $screen_name . " __nsfw" );

# $some_feed->{title} = $renamed_feed->{title}; ## should be handled by the object
        }
    }

}

