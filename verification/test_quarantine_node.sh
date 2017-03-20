#!/usr/bin/env bash

quarantine_node_label="region=quarantine"
new_node_label="region=new"
quarantine_project_annotation="openshift.io/node-selector=region=quarantine"
test_project=quarantine-test
test_buildconfig=devex-quarantine-build
test_node=$1
build_count=$2

#echo "Testing node '$test_node' using project '$test_project' with '$build_count' builds..."

oc project $test_project

# remove all nodes from quarantine
oc label --overwrite node -l $quarantine_node_label $new_node_label

# add target node into quarantine
#oc label --overwrite node $test_node $quarantine_node_label

# add *all* new nodes to quarantine
oc label --overwrite node -l $new_node_label $quarantine_node_label

oc annotate  --overwrite namespace $test_project $quarantine_project_annotation

oc start-build $test_buildconfig -n $test_project

oc get builds --no-headers -n $test_project -o wide -w | ../utils/build_hammer.py $build_count
