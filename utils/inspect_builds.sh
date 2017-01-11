#!/usr/bin/env bash

for project in $(oc get projects --no-headers | awk '{print $1}');
do
#    echo "project: $project";
#    for build in $(oc get builds -n $project --no-headers | awk '/Failed|Cancelled/' | awk '/hours/{print $1}');
    for build in $(oc get builds -n $project --no-headers  | awk '/hours/{print $1}');
        do
            build_status=`oc describe build $build -n $project | awk '/Status/{print $2}'`
            build_started=`oc describe build $build -n $project | awk '/Started/{$1=""; print $0}'`
            build_duration=`oc describe build $build -n $project | awk '/Duration/{print $2}'`
            build_created=`oc describe build $build -n $project | awk '/Created/{$1=""; print $0}'`
            build_pod=`oc describe build $build -n $project | awk '/Build Pod/{print $3}'`
            build_host=`oc describe pod -n $project $build_pod | awk '/Node/{print $2}'`

            echo "$project build $build created at $build_created and $build_status in pod $build_pod on host $build_host after $build_duration"
        done
done
