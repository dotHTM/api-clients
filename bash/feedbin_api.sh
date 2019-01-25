#!/usr/bin/env bash
# FeedbinClient.sh


BASE_URL='https://api.feedbin.com/v2'

source "./config.sh"

post(){
    url=$1 && shift
    data=$1 && shift
    # echo "url  => ${url}"
    # echo "data => ${data}"
    curl -s -H "Content-Type: application/json" --request POST --user "${USER}:${PASSWORD}" -d "$data" "${url}" 2>&1
    echo
}


get(){
    url=$1 && shift
    echo "${url}"
    curl -s --request GET --user "${USER}:${PASSWORD}" -X GET "${url}" 2>&1
    echo
}


auth_test(){
    get "${BASE_URL}/authentication.json"
}

get_subscriptions(){
    get "${BASE_URL}/subscriptions.json"
}

get_taggings(){
    get "${BASE_URL}/taggings.json"
}

get_subs(){
    get "${BASE_URL}/subscriptions.json"
}


get_sub(){
    sub_id=$1 && shift
    get "${BASE_URL}/subscriptions/${sub_id}.json"
}

create_sub(){
    feed_url=$1 && shift
    post "${BASE_URL}/subscriptions.json" "{ \"feed_url\": \"${feed_url}\" }"
}


tag_feed(){
    feed_id=$1 && shift
    tag_name=$1 && shift
    data="{ \"feed_id\": \"${feed_id}\", \"name\": \"${tag_name}\" }"
    post "${BASE_URL}/taggings.json" "$data"
}


rename_feed(){
    sub_id=$1 && shift
    new_name=$1 && shift
    echo "${sub_id} => ${new_name}"
    data="{ \"title\": \"${new_name}\" }"
    post "${BASE_URL}/subscriptions/${sub_id}/update.json" "$data"
}
