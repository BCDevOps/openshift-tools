#!/usr/bin/env bash

for project in $(oc get projects --no-headers | awk '{print $1}');
    do
        quota_count=$(oc get quota compute-resources --no-headers -n $project 2> /dev/null | wc -l | xargs echo -n | awk '{ print; }')
          if [ "$quota_count" -gt "0" ]
          then
            pct=$(oc describe quota compute-resources -n $project | awk -v project=$project '/limits.cpu/{ ($2 ~ /m/) ? cores= $2 / 1000  : cores = $2 ; use = cores / $3 ; pct = use * 100 ; print pct; }')
            echo "$project $pct"
          fi
    done