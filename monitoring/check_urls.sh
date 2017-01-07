#!/usr/bin/env bash

while :
do
  echo "================="
  echo 'Starting a run.'
  echo "================="
  oc get routes --all-namespaces | awk 'NR>1' | python check_urls.py
  echo "================="
  echo "Run complete... Grabbing a coffee before next run..."
  echo "================="
  sleep 10
done
