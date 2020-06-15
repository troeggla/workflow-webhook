#!/bin/bash

set -e

if [ -z "$webhook_url" ]; then
    echo "No webhook_url configured"
    exit 1
fi

if [ -z "$webhook_secret" ]; then
    echo "No webhook_secret configured"
    exit 1
fi

DATA_JSON="\"repository\":\"$GITHUB_REPOSITORY\",\"ref\":\"$GITHUB_REF\",\"commit\":\"$GITHUB_SHA\",\"trigger\":\"$GITHUB_EVENT_NAME\",\"workflow\":\"$GITHUB_WORKFLOW\""

if [ -n "$data" ]; then
    COMPACT_JSON=$(echo -n "$data" | jq -c '')
    WEBHOOK_DATA="{$DATA_JSON,\"data\":$COMPACT_JSON}"
else
    WEBHOOK_DATA="{$DATA_JSON}"
fi

WEBHOOK_SIGNATURE=$(echo -n "$WEBHOOK_DATA" | openssl sha1 -hmac "$webhook_secret" -binary | xxd -p)

WEBHOOK_ENDPOINT=$webhook_url
if [ -n "$webhook_auth" ]; then
    WEBHOOK_ENDPOINT="-u $webhook_auth $webhook_url"
fi

curl -X POST \
    -H "Content-Type: application/json" \
    -H "User-Agent: User-Agent: GitHub-Hookshot/760256b" \
    -H "X-Hub-Signature: sha1=$WEBHOOK_SIGNATURE" \
    -H "X-Github-Delivery: $GITHUB_RUN_NUMBER" \
    -H "X-Github-Event: $GITHUB_EVENT_NAME" \
    --data "$WEBHOOK_DATA" $WEBHOOK_ENDPOINT
