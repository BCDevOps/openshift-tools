#!/usr/bin/env bash

usage(){
	echo "Usage: $0 -i <IMAGESTREAM_NAME> -b <BUIlD_CONFIG> -t <JENKINSFILE_TEMPLATE (optional)>"
	exit 1
}

TEMPLATE="./resources/Jenkinsfile-template.txt"

while getopts ":i:b:t:" opt; do
  case $opt in
    i)
      IMAGESTREAM_NAME=$OPTARG
      ;;
    b)
      BUILD_CONFIG=$OPTARG
      ;;
    t)
      TEMPLATE=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

if [ -z "$IMAGESTREAM_NAME" ] || [ -z "$BUILD_CONFIG" ] || [ -z "$TEMPLATE" ]
then
    echo "Missing required parameters..."
    usage
    exit -1
fi

echo "OpenShift ImageStream name is '$IMAGESTREAM_NAME'" >&2
echo "OpenShift BuildConfiguration is '$BUILD_CONFIG'" >&2
echo "Jenkinsfile template is '$TEMPLATE'" >&2

export IMAGESTREAM_NAME=$IMAGESTREAM_NAME
export BUILD_CONFIG=$BUILD_CONFIG

envsubst '${IMAGESTREAM_NAME} ${BUILD_CONFIG}' < ${TEMPLATE}

echo "Jenkinsfile has been generated for you, above ^^^. Copy this into your GitHub repo and point to it when you run 'create-pipeline.sh'"
