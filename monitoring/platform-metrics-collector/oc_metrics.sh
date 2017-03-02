#!/bin/sh

while [ 1 ]
do
    pod_count=$(oc get pods)
    echo "Pod count is '$pod_count'"

    curl -i -XPOST 'http://influxdb:8186/write' --data-binary "pod_count,project=myproject value=$pod_count"

    sleep 30
done
