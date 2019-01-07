#!/bin/bash
# script to merge the template variable file with the different object files, process and create.

# install log rotate script, cronjob, service account
cat vars-log-rotate.yaml cm-log-rotate.yaml tmpl-cronjob.yaml tmpl-service-accounts.yaml \
  |  oc process -f - | oc apply -f -

# install registry soft prune script, cronjob, service account
cat vars-registry-soft-prune.yaml cm-registry-soft-prune.yaml tmpl-cronjob.yaml tmpl-service-accounts.yaml \
  |  oc process -f - | oc apply -f -

# install registry hard prune script, cronjob, (skipping servicat vars-registry-soft-prune.yaml cm-registry-soft-prune.yaml tmpl-cronjob.yaml tmpl-service-accounts.yaml |  oc process -f - | oc create -f -ce account)
cat vars-registry-hard-prune.yaml cm-registry-hard-prune.yaml tmpl-cronjob.yaml |  oc process -f - | oc apply -f -
