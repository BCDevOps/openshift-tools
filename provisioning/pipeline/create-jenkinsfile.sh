#!/usr/bin/env bash

usage(){
	echo "Usage: $0 -i <IMAGESTREAM_NAME> -d <DEPLOYMENT_CONFIG> -t <JENKINSFILE_TEMPLATE (optional)>"
	exit 1
}

TEMPLATE="./resources/Jenkinsfile-template.txt"

while getopts ":i:d:t:" opt; do
  case $opt in
    i)
      IMAGESTREAM_NAME=$OPTARG
      ;;
    d)
      DEPLOYMENT_CONFIG=$OPTARG
      ;;
    t)
      TEMPLATE=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

if [ -z "$IMAGESTREAM_NAME" ] || [ -z "$DEPLOYMENT_CONFIG" ] || [ -z "$TEMPLATE" ]
then
    echo "Missing required parameters..."
    usage
    exit -1
fi

echo "OpenShift ImageStream name is '$IMAGESTREAM_NAME'" >&2
echo "OpenShift DeploymentConfiguration is '$DEPLOYMENT_CONFIG'" >&2
echo "Jenkinsfile template is '$TEMPLATE'" >&2

export IMAGESTREAM_NAME=$IMAGESTREAM_NAME
export DEPLOYMENT_CONFIG=$DEPLOYMENT_CONFIG

envsubst '${IMAGESTREAM_NAME} ${DEPLOYMENT_CONFIG}' < ${TEMPLATE}
#envsubst '${IMAGESTREAM_NAME} ${DEPLOYMENT_CONFIG}' < ${TEMPLATE} > ./Jenkinsfile

echo "A Jenkinsfile has been created for you in this directory. You can place this in your GitHub repo and point to it when you run 'create-pipeline.sh'"
