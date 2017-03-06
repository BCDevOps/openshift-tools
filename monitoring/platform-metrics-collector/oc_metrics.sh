#!/bin/sh

while [ 1 ]
do
    pod_count=$(oc get pods --no-headers --all-namespaces | grep Running | wc -l | tr -d '[:space:]')

    ts_secs=$(date +%s)
    ts_nano="$(($ts_secs * 1000000000))"

    payload="pod_count,scope=cluster pods=${pod_count} $ts_nano"
    echo "$payload"

    curl -s -i -XPOST "http://${TELEGRAF_HTTP_SERVICE_HOST}:8186/write" --data-binary "$payload"

    sleep 30
done
