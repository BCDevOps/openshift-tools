#!/usr/bin/env bash

# Exit on error. Append "|| true" if you expect an error.
set -o errexit
# Exit on error inside any functions or subshells.
set -o errtrace
# Do not allow use of undefined vars. Use ${VAR:-} to use an undefined VAR
set -o nounset
# Catch the error in case mysqldump fails (but gzip succeeds) in `mysqldump |gzip`
set -o pipefail
# Turn on traces, useful while debugging but commented out by default
# set -o xtrace

# Send alerts to this address
MAILTO="-r from@dxcas.com to@dxcas.com"

export KUBECONFIG=/root/pruner/pruner.kubeconfig

LOGLEVEL="--loglevel=4"

KEEP="--keep-younger-than=96h"

DATE=$(date "+%Y%m%d_%H%M%S")

LOG_DIR="/var/log/oc-prune"

# Dry run of builds cleanup
/bin/oadm prune builds --orphans $KEEP $LOGLEVEL > "${LOG_DIR}/${DATE}.builds.dryrun.log" 2> "${LOG_DIR}/${DATE}.builds.dryrun.err"
if [ $? -ne 0 ]
then
        cat "${LOG_DIR}/${DATE}.builds.dryrun.err" "${LOG_DIR}/${DATE}.builds.dryrun.log" | mail -s "OpenShift Prune Failed" $MAILTO
        exit 1
fi

# Clean up builds
/bin/oadm prune builds --orphans $KEEP $LOGLEVEL --confirm > "${LOG_DIR}/${DATE}.builds.run.log" 2> "${LOG_DIR}/${DATE}.builds.run.err"
if [ $? -ne 0 ]
then
        cat "${LOG_DIR}/${DATE}.builds.run.err" "${LOG_DIR}/${DATE}.builds.run.log"  | mail -s "OpenShift Prune Failed" $MAILTO
        exit 1
fi

# Dry run of deployments cleanup
/bin/oadm prune deployments --orphans $KEEP $LOGLEVEL > "${LOG_DIR}/${DATE}.deployments.dryrun.log" 2> "${LOG_DIR}/${DATE}.deployments.dryrun.err"
if [ $? -ne 0 ]
then
        cat "${LOG_DIR}/${DATE}.deployments.dryrun.err" "${LOG_DIR}/${DATE}.deployments.dryrun.log" | mail -s "OpenShift Prune Failed" $MAILTO
        exit 1
fi

# Clean up deployments
/bin/oadm prune deployments --orphans $KEEP $LOGLEVEL --confirm > "${LOG_DIR}/${DATE}.deployments.run.log" 2> "${LOG_DIR}/${DATE}.deployments.run.err"
if [ $? -ne 0 ]
then
        cat "${LOG_DIR}/${DATE}.deployments.run.err" "${LOG_DIR}/${DATE}.deployments.run.log" | mail -s "OpenShift Prune Failed" $MAILTO
        exit 1
fi

# Dry run of images cleanup
/bin/oadm prune images $KEEP $LOGLEVEL > "${LOG_DIR}/${DATE}.images.dryrun.log" 2> "${LOG_DIR}/${DATE}.images.dryrun.err"
if [ $? -ne 0 ]
then
        cat "${LOG_DIR}/${DATE}.images.dryrun.err" "${LOG_DIR}/${DATE}.images.dryrun.log" | mail -s "OpenShift Prune Failed" $MAILTO
        exit 1
fi

# Clean up images
/bin/oadm prune images $KEEP $LOGLEVEL --confirm > "${LOG_DIR}/${DATE}.images.run.log" 2> "${LOG_DIR}/${DATE}.images.run.err"
if [ $? -ne 0 ]
then
        cat "${LOG_DIR}/${DATE}.images.run.err" "${LOG_DIR}/${DATE}.images.run.log" | mail -s "OpenShift Prune Failed" $MAILTO
        exit 1
fi

ansible nodes -m shell -a "journalctl -u atomic-openshift-node --since -24h | grep ImagePullBackOff" > "${LOG_DIR}/${DATE}.Node-ImagePullBackOff.out"||true

ansible nodes -m shell -a "journalctl -u atomic-openshift-node --since -24h | grep ErrImagePull" > "${LOG_DIR}/${DATE}.Node-ErrImagePull.out"||true
