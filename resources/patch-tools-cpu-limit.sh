#!/bin/bash
# 
# Patch CPU limit quota for all tools projecs
#
for P in $(oc get projects -o name|sed 's#projects/##');
do
  if [[ "$P" == *tools ]]
  then
    Q=$(oc -n $P get quota -o name);
    if [ -n "$Q" ]
    then
      echo "$Q >  $P";
      oc -n $P patch $Q -p '{"spec":{"hard":{"limits.cpu": 12}}}'
    fi
  fi
done
