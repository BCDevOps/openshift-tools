#!/bin/sh

while [ 1 ]
do
    pod_count=$(oc get pods --no-headers | wc -l)
    echo "Pod count is '$pod_count'"

    ts_secs=$(date +%s)
    ts_nano="$(($ts_secs * 1000000))"

    curl -i -XPOST "http://${TELEGRAF_HTTP_SERVICE_HOST}:8186/write" --data-binary "pod_count,project=myproject value=${pod_count} $ts_nano"

    sleep 30
done
