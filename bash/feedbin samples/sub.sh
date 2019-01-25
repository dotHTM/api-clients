#!/usr/bin/env bash

## FIXME:: Tabbed lines in the input file might be NOT be Ingored in this implementation.

source "./FeedbinClient.sh"

add_twitter_follow(){
    some_user=$1 && shift
    tag_list=$*
    if [[ -n "$some_user" ]]; then
        echo
        echo "= $some_user ==================================================="
        request_return=`create_sub "twitter.com/${some_user}"`
        echo "request_return => $request_return"
        my_feed_id=`echo ${request_return} | jq '.feed_id'`
        my_id=`echo ${request_return} | jq '.id'`
        my_feed_name=`echo ${request_return} | jq '.title' | perl -pe 's/\"//gmi'`
        tag_feed "$my_feed_id" 'x.8.0 Bankrupt'
        has_tags=0
        for some_tag in $tag_list; do
            has_tags=1
            if [[ "${some_tag}" =~ _nsfw$ ]]; then
                tag_feed "$my_feed_id" "x.8.8 ${some_tag}"
                rename_feed "${my_id}" "@${some_user} __nsfw"
            else
                tag_feed "$my_feed_id" "x.8.5 ${some_tag}"
                if [[ "${some_tag}" =~ _safe$ ]]; then
                    rename_feed "${my_id}" "@${some_user}"
                fi
            fi
        done
        if [[ $has_tags == 0 ]]; then
            tag_feed "$my_feed_id" 'x.8.9 import'
        fi
    fi
}

backup(){
    mkdir -p 'backup'
    get_subscriptions >> "backup/${run_time}_sub.json"
    get_taggings >> "backup/${run_time}_tag.json"
    backup_link="https://feedbin.com/subscriptions.xml?utf8=✓&tag=all"
    open -a /Applications/Safari.app ${backup_link}
}





run_time=`date "+%Y%m%d-%H%M%S"`

auth_test
# backup
while read some_screen_name some_tag; do
    add_twitter_follow "$some_screen_name" "$some_tag"
done <<< `cat categorized.txt`
