#!/usr/bin/env bash

for project in $(oc get projects --no-headers | awk '{print $1}');
do
#    echo "project: $project";
#    for build in $(oc get builds -n $project --no-headers | awk '/Failed|Cancelled/' | awk '/hours/{print $1}');
    for build in $(oc get builds -n $project --no-headers | awk '/hours/{print $1}');
        do
            build_description=$(oc describe build $build -n $project)
            build_status=`echo "$build_description" | awk '/Status/{print $2}'`
            build_started=`echo "$build_description" | awk '/Started/{$1=""; print $0}'`
            build_duration=`echo "$build_description" | awk '/Duration/{print $2}'`
            build_created=`echo "$build_description" | awk '/Created/{$1=""; print $0}'`
            build_pod=$(echo "$build_description" | awk '/Build Pod/{print $3}')
            pod_description=$(oc describe pod -n $project $build_pod)
            build_host=`echo "$pod_description" | awk '/Node/{print $2}'`
            security_policy=`echo "$pod_description" | awk '/Security Policy/{print $3}'`

            echo "$project build $build created at $build_created and $build_status in pod $build_pod on host $build_host with $security_policy after $build_duration"
        done
done
