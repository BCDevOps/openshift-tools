#!/usr/bin/env bash

while getopts ":i:d:" opt; do
  case $opt in
    i)
      IMAGESTREAM_NAME=$OPTARG
      echo "imagestream name is '$IMAGESTREAM_NAME'" >&2
      ;;
    d)
      DEPLOYMENT_CONFIG=$OPTARG
      echo "OpenShift DeploymentConfiguration is '$DEPLOYMENT_CONFIG'" >&2
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

export IMAGESTREAM_NAME=$IMAGESTREAM_NAME
export DEPLOYMENT_CONFIG=$DEPLOYMENT_CONFIG

envsubst '${IMAGESTREAM_NAME} ${DEPLOYMENT_CONFIG}' < ./resources/Jenkinsfile-template.txt > ./Jenkinsfile

echo "A Jenkinsfile has been created for you in this directory. You can place this in your GitHub repo and point to it when you run 'create-pipeline.sh'"
