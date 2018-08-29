#!/usr/bin/env bash

# usage:

# to add a label `project_type=user` to a bunch of projects:
# ./edit_project_label.sh project_type=user $(oc get projects -l 'category in (pathfinder,spark,venture)' --no-headers | awk 'BEGIN{ORS=" "} {print $1}' )
#
# to remove a label `project_type` from a bunch of projects:
# ./edit_project_label.sh project_type- $(oc get projects -l 'category in (pathfinder,spark,venture)' --no-headers | awk 'BEGIN{ORS=" "} {print $1}' )

LABEL=$1

echo "Label is $LABEL"

for OS_PROJECT_NAME in "${@:2}"; do
	echo "Project : $OS_PROJECT_NAME, Label: $LABEL"
    oc label namespace/$OS_PROJECT_NAME $LABEL
done
