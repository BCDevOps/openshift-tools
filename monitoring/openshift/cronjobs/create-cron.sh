#!/bin/bash
# script to merge the template variable file with the different object files, process and create.

# Create an ImageStream and a BuildConfig to build the cron-job runner image
oc apply -f build.yaml

# install log rotate script, cronjob, service account
cat vars-log-rotate.yaml tmpl-cronjob.yaml tmpl-service-accounts.yaml \
  |  oc process -f - | oc apply -f -

# install registry soft prune script, cronjob, service account
cat vars-registry-soft-prune.yaml tmpl-cronjob.yaml tmpl-service-accounts.yaml \
  |  oc process -f - | oc apply -f -

# install registry hard prune script, cronjob, (skipping servicat vars-registry-soft-prune.yaml cm-registry-soft-prune.yaml tmpl-cronjob.yaml tmpl-service-accounts.yaml |  oc process -f - | oc create -f -ce account)
cat vars-registry-hard-prune.yaml tmpl-cronjob.yaml |  oc process -f - | oc apply -f -
