#!/usr/bin/env bash

while getopts ":b:p:" opt; do
  case $opt in
    b)
      BUILD_NAME=$OPTARG
      echo "build pipeline name is '$BUILD_NAME'" >&2
      ;;
    p)
      OPENSHIFT_PROJECT=$OPTARG
      echo "OpenShift project is '$OPENSHIFT_PROJECT'" >&2
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

oc process -f resources/pipeline-build.json -v NAME=${BUILD_NAME} -v CONTEXT_DIR=provisioning/resources | oc create -n ${OPENSHIFT_PROJECT}  -f -
