#!/usr/bin/env bash

echo -n "Enter the name of the image from DockerHub that you'd like to use: "
read DOCKERHUB_IMAGE
echo -n "Enter the name of your OpenShift project: "
read OPENSHIFT_NAMESPACE

docker pull $DOCKERHUB_IMAGE

OPENSHIFT_IMAGE_SNIPPET=${DOCKERHUB_IMAGE#*/}

OPENSHIFT_REGISTRY_ADDRESS=docker-registry.pathfinder.gov.bc.ca
OPENSHIFT_IMAGESTREAM_PATH=${OPENSHIFT_REGISTRY_ADDRESS}/${OPENSHIFT_NAMESPACE}/${OPENSHIFT_IMAGE_SNIPPET}

docker tag $DOCKERHUB_IMAGE $OPENSHIFT_IMAGESTREAM_PATH

docker login ${OPENSHIFT_REGISTRY_ADDRESS} -u $(oc whoami) -p $(oc whoami -t)

docker push $OPENSHIFT_IMAGESTREAM_PATH




