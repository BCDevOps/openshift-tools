#!/usr/bin/env bash

## User Tunables
# Project to run test in, will be deleted if it exists
PROJECT=node-validation
# App template to use
# django-psql-persistent is nice because it contains the most things to
# excersise. A S2I build, a Service, a DeploymentController, a
# Persistent Volume, and a route.
TEMPLATE=django-psql-persistent

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

# Print a backtrace on error
# https://github.com/ab/bin/blob/master/bash-backtrace.sh
bash_backtrace() {
    # Return value of command that caused error
    local RET=$?
    # Frame counter
    local I=0
    # backtrace layers
    local FRAMES=${#BASH_SOURCE[@]}

    # Restore STDOUT and STDERR as they might be in unknown states due to catching
    # an error in the middle of a command
    exec 1>&3 2>&4

    error "Traceback (most recent call last):"

    for ((FRAME=FRAMES-2; FRAME >= 0; FRAME--)); do
        local LINENO=${BASH_LINENO[FRAME]}

        # Location of error
        error "  File ${BASH_SOURCE[FRAME+1]}, line ${LINENO}, in ${FUNCNAME[FRAME+1]}"

        # Print the error line, with preceding whitespace removed
        error "$(sed -n "${LINENO}s/^[   ]*/    /p" "${BASH_SOURCE[FRAME+1]}")"
    done

    error "Exiting with status ${RET}"
    exit "${RET}"
}

# Copy STDOUT and STDERR so they can be restored later
exec 3>&1 4>&2
# Trap script errors and print some helpful debug info
trap bash_backtrace ERR

# Create some colour vars
RESET="\e[39m"
GREEN="\e[92m"
YELLOW="\e[93m"
RED="\e[91m"

# Shortcut to green success messages
function success () {
    echo -e "${GREEN}${1:-}${RESET}"
}

# Shortcut to yellow warning messages
function warn () {
    echo -e "${YELLOW}${1:-}${RESET}"
}

# Shortcut to red error messages
# Sent to STDERR
function error () {
    echo >&2 -e "${RED}${1:-}${RESET}"
}

# Parse Arguments
while [[ -n "${1:-}" ]]
do
    case "${1}" in
        --help)
            echo "$(basename $0) <selector>"
            echo
            echo "This script will test each node individually where <selector> is a lable of nodes."
            echo "eg: region=quarantine or hostType=virtual"
            exit
            ;;
        *)
            SELECTOR="${1}"
            shift
            ;;
    esac
done

# Confirm selector is set
if [[ -z "${SELECTOR:-}" ]]
then
    error "Please set a selector!"
    exit 1
fi

# Confirm selector matches nodes
NODE_COUNT=$(oc get nodes -o name --selector "${SELECTOR}" | wc -l)
if [[ "${NODE_COUNT}" -lt 1 ]]
then
    error "${SELECTOR} doesn't match any nodes"
    exit 1
fi

# Delete old validation project if it exists
if oc get project "${PROJECT}" >/dev/null 2>&1
then
    warn "Cleaning up old project '${PROJECT}'"
    oc delete project "${PROJECT}"
    # Prevent new-project from failing
    while oc get project "${PROJECT}" >/dev/null 2>&1
    do
        echo -n .
        sleep 1
    done
    echo
fi

# Create project for testing
oc new-project "${PROJECT}" >/dev/null

# For each node
for NODE in $(oc get nodes -o name --selector "${SELECTOR}" | sed 's/nodes*\///')
do
    echo "=== Testing $NODE"
    # Set project to use node
    echo "Setting project to target node"
    oc patch namespace "${PROJECT}" -p '{"metadata":{"annotations": {"openshift.io/node-selector": "kubernetes.io/hostname='"${NODE}"'"}}}' >/dev/null

    # Fire up a new Django app
    echo "Creating app"
    oc new-app -n "${PROJECT}" "${TEMPLATE}" >/dev/null

    # Wait for build to start
    echo "Build Starting"
    STATUS=
    until [[ "${STATUS}" = "Running" ]]
    do
        sleep 1
        STATUS=$(oc get pod -n "${PROJECT}" -o custom-columns=STATUS:.status.phase --no-headers "${TEMPLATE}-1-build")
    done

    # Follow the build
    echo "Building"
    oc logs -f -n "${PROJECT}" "pod/${TEMPLATE}-1-build" >/dev/null

    # Wait for deploy to start
    echo "Deploy starting"
    STATUS=
    until [[ "${STATUS}" = "Running" ]]
    do
        sleep 1
        STATUS=$(oc get pod -n "${PROJECT}" -o custom-columns=STATUS:.status.phase --no-headers "${TEMPLATE}-1-deploy")
    done

    # Follow the app deploy
    echo "Deploying"
    oc logs -f -n "${PROJECT}" "pod/${TEMPLATE}-1-deploy" >/dev/null

    # Test the route
    URL=$(oc describe route -n "${PROJECT}" "${TEMPLATE}" | awk '/Requested Host/ {print $3}')
    RETRY=5
    while :
    do
        HTTP_CODE=$(curl -sL -w "%{http_code}" -o /dev/null "http://${URL}/")
        if [[ "${HTTP_CODE}" -eq 200 ]]
        then
            success "Route returned 200 OK"
            break
        elif [[ $RETRY -gt 0 ]]
        then
            warn "Route returned ${HTTP_CODE}, retrying"
            sleep 5
            let "RETRY--"
        else
            error "Route returned ${HTTP_CODE}"
            exit 1
        fi
    done

    # Delete successful deploy
    echo "Cleanup"
    oc delete all,secrets,pvc -n "${PROJECT}" --selector "app=${TEMPLATE}" >/dev/null || true
    # Ensure everything is gone
    while [[ $(oc get all,secrets,pvc -n "${PROJECT}" --selector "app=${TEMPLATE}" --no-headers -o name | wc -l) -gt 0 ]]
    do
        echo -n .
        sleep 1
    done
    echo

done

# Clean up
oc delete project "${PROJECT}"
