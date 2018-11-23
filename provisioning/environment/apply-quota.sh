#!/usr/bin/env bash
set -Eeuo pipefail

TEMPLATE_NAME="$1"
PRODUCT_NAME="$2"
PROJECT_SUFFIX="$3"


ADMIN_USER="system:serviceaccount:openshift:bcdevops-admin"
TEMP_NAMESPACE="bcgov-tools"


rm -rf temp*.json
rm -rf temp*.lst

#Process Template

oc "--as=$ADMIN_USER" -n "${TEMP_NAMESPACE}"  process -f "templates/openshift-${TEMPLATE_NAME}.yaml" -p "NAME=${PRODUCT_NAME}" -o json > temp.json

#Generate list of Project/Namespace
jq -r "[.items[] | select(.metadata.namespace != null and .metadata.namespace == \"${PRODUCT_NAME}-${PROJECT_SUFFIX}\") | .metadata.namespace] | unique | .[]" temp.json > temp.namespaces.lst

#Apply Quota and any other namespace-specific object
while read namespace; do ( jq -r "{\"kind\":\"List\", \"items\":[.items[] | select(.metadata.namespace == \"$namespace\" and .kind == \"ResourceQuota\")]}" temp.json | oc "--as=$ADMIN_USER" -n "$namespace" apply -f - ); done < "temp.namespaces.lst"

while read namespace; do ( oc "--as=$ADMIN_USER" -n "$namespace" delete resourcequota/compute-resources ); done < "temp.namespaces.lst"
