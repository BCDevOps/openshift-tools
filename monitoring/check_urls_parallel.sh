#!/usr/bin/env bash

oc get routes --all-namespaces | awk 'NR>1' | python check_urls_parallel.py
