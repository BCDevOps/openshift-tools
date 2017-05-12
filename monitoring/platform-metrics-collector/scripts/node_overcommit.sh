#!/usr/bin/env bash

for node in $(oc get nodes --no-headers -l region=app| awk '{print $1}')
    do
        overcommit=$(oc describe node $node | grep -A4 Allocated | awk 'NR == 5 {print $4}')
        echo $node $overcommit
    done

