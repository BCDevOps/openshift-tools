#!/usr/bin/env bash

for project in $(oc get projects --no-headers | awk '{print $1}');
    do
      result=$(oc get quota compute-resources --no-headers -n $project 2> /dev/null | wc -l | xargs echo -n | awk '{ print; }')
      if [ "$result" -gt "0" ]
      then
        echo "Project $project has a quota"
      fi
    done