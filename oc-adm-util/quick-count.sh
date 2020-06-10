#!/bin/bash
# get prod namespaces:
oc get project -o json | jq -M '[.items[] | select(.metadata.name | contains ("-prod")) | .metadata.labels + {"namespace": .metadata.name} + {"created": .metadata.creationTimestamp}]' > output/projects.json

# 0. total count months:
numberMonth=6

for ((i = numberMonth; i >= 0; i--)); do
# 1. setup timestamp:
  startTime=$(date "-v-${i}m" -u +"%Y-%m-00T00:00:00Z")

  if (($i > 0)); then
    j=$(( i - 1 ))
    endTime=$(date "-v-${j}m" -u +"%Y-%m-00T00:00:00Z")
  else
    endTime=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  fi

# 2. filter namespace by time:
  # ---- More details:
  # echo "From $i month ago ( $startTime to $endTime ):"
  # jq -r '.[] | select((.created > '\"$startTime\"') and (.created <= '\"$endTime\"')) | .namespace' output/projects.json
  # ----- Few details:
  date "-v-${i}m" +'Project sets created during %B'
  jq -r '.[] | select((.created >= '\"$startTime\"') and (.created < '\"$endTime\"')) | .namespace' output/projects.json | wc -l
done