#!/bin/bash

# Exit if we encounter an unset variable
set -o nounset

# Send alerts to this address
MAILTO="XXXX@XXXX.com"

export KUBECONFIG=/root/pruner/pruner.kubeconfig

# Dry run of builds cleanup
DR_BUILDS=$(/bin/oadm prune builds --orphans --keep-younger-than=96h 2>&1)
if [ $? -ne 0 ]
then
        echo -e "Dry run:\n$DR_BUILDS" | mail -s "OpenShift Prune Failed" $MAILTO
        exit 1
fi

# Clean up builds
BUILDS=$(/bin/oadm prune builds --orphans --keep-younger-than=96h --confirm 2>&1)
if [ $? -ne 0 ]
then
        echo -e "Run:\n$BUILDS\n\nDry run:\n$DR_BUILDS" | mail -s "OpenShift Prune Failed" $MAILTO
        exit 1
fi
exit 2
# Dry run of deployments cleanup
DR_DEPLOY=$(/bin/oadm prune deployments --orphans --keep-younger-than=96h 2>&1)
if [ $? -ne 0 ]
then
        echo -e "Dry run:\n$DR_DEPLOY" | mail -s "OpenShift Prune Failed" $MAILTO
        exit 1
fi

# Clean up deployments
DEPLOY=$(/bin/oadm prune deployments --orphans --keep-younger-than=96h --confirm 2>&1)
if [ $? -ne 0 ]
then
        echo -e "Run:\n$DEPLOY\n\nDry run:\n$DR_DEPLOY" | mail -s "OpenShift Prune Failed" $MAILTO
        exit 1
fi

# Dry run of images cleanup
DR_IMAGES=$(/bin/oadm prune images --keep-younger-than=96h 2>&1)
if [ $? -ne 0 ]
then
        echo -e "Dry run:\n$DR_IMAGES" | mail -s "OpenShift Prune Failed" $MAILTO
        exit 1
fi

# Clean up images
IMAGES=$(/bin/oadm prune images --keep-younger-than=96h --confirm 2>&1)
if [ $? -ne 0 ]
then
        echo -e "Run:\n$IMAGES\n\nDry run:\n$DR_IMAGES" | mail -s "OpenShift Prune Failed" $MAILTO
        exit 1
fi

