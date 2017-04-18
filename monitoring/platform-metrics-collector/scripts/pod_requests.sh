#!/usr/bin/env bash

function display_pod() {
    pod=$1
    project=$2

    request=$(oc describe pod $pod -n $project | grep -A4 Requests | awk -v project=$project -v pod=$pod '/cpu/{ ($2 ~ /m/) ? cores = $2 / 1000 : cores = $2 ; print project"/"pod": " cores }')
    echo $request
}
function display_project_pods() {
    project=$1

    for pod in $(oc get pods --no-headers -n $project | awk '/Running/{print $1}');
    do
        display_pod $pod $project
    done
}

if [ -z "$1" ]
then
    for project in $(oc get projects --no-headers | awk '{print $1}');
        do
            display_project_pods $project
        done
else
    display_project_pods $1
fi