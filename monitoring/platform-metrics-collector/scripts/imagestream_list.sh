#!/usr/bin/env bash

function display_imagestream() {

    project=$1
    dc=$2
#    imagestream=$(oc export dc $dc -n $project -o=jsonpath --template="{.spec.triggers[0].imageChangeParams.from.namespace}/{.spec.triggers[0].imageChangeParams.from.name}")
#    imagestream=$(oc export dc $dc -n $project -o=jsonpath --template="{.spec.triggers[0].imageChangeParams}")
    imagestream=$(oc export dc $dc -n $project -o=jsonpath --template="{.spec.triggers[*].imageChangeParams.from.namespace}/{.spec.triggers[*].imageChangeParams.from.name}")

    echo $project/$dc $imagestream

}

function display_project_imagestreams() {
    project=$1

    for dc in $(oc get dc --no-headers -n $project | awk '{print $1}');
    do
        display_imagestream $project $dc
    done
}

if [ -z "$1" ]
then
    for project in $(oc get projects --no-headers | awk '{print $1}');
        do
            display_project_imagestreams $project
        done
else
    display_project_imagestreams $1
fi
