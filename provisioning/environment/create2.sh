#!/usr/bin/env bash
set -Eeuo pipefail

TEMPLATE_NAME="$1"
ADMIN_USER="system:serviceaccount:openshift:bcdevops-admin"
TEMP_NAMESPACE="bcgov-tools"


if [ ! -f input.env ]; then
    echo "ERROR: Missing input.env file."
    exit 1
fi

if [ ! -f "templates/openshift-${TEMPLATE_NAME}.yaml" ]; then
    echo "ERROR: Teplate not found (templates/openshift-${TEMPLATE_NAME}.yaml)"
    exit 1
fi

rm -rf temp*.json
rm -rf temp*.lst

#Process Template

oc "--as=$ADMIN_USER" -n "${TEMP_NAMESPACE}"  process -f "templates/openshift-${TEMPLATE_NAME}.yaml" --param-file=input.env -o json > temp.json

#Generate list of Project/Namespace
jq -r '[.items[] | select(.metadata.namespace != null) | .metadata.namespace] | unique | .[]' temp.json > temp.namespaces.lst

#Create Namespace/Project
while read namespace; do ( oc "--as=$ADMIN_USER" get "namespace/$namespace" >/dev/null 2>&1 || oc "--as=$ADMIN_USER" new-project "$namespace" ); done < "temp.namespaces.lst"

#Update Project Metadata labels/annotations
while read namespace; do ( jq -r "{\"kind\":\"List\", \"items\":[.items[] | select(.kind == \"Project\" and .metadata.name == \"$namespace\") | .kind = \"Namespace\" | .apiVersion = \"v1\"]}" temp.json | oc "--as=$ADMIN_USER" -n "$namespace" apply -f - ); done < "temp.namespaces.lst"

#Exporting the configuration for each project
#while read namespace; do ( jq -r "{\"kind\":\"List\", \"items\":[.items[] | select(.metadata.namespace == \"$namespace\")]}" temp.json > "temp-$namespace.json" ); done < "temp.namespaces.lst"

#Cleanup default stuff
while read namespace; do ( oc  "--as=$ADMIN_USER" "--namespace=$namespace" delete ResourceQuota -l '!custom' --ignore-not-found=true  ); done < "temp.namespaces.lst"

#Apply Quota and any other namespace-specific object
while read namespace; do ( jq -r "{\"kind\":\"List\", \"items\":[.items[] | select(.metadata.namespace == \"$namespace\")]}" temp.json | oc "--as=$ADMIN_USER" -n "$namespace" apply -f - ); done < "temp.namespaces.lst"


#If there is a custom ResourceQuota, delete teh dafault one

#oc --as=system:serviceaccount:openshift:bcdevops-admin delete namespace/vr5evj-tools namespace/vr5evj-dev  namespace/vr5evj-test namespace/vr5evj-prod 
#oc --as=system:serviceaccount:openshift:bcdevops-admin -nfuwy62ys-dev delete RoleBinding --all
#oc --as=system:serviceaccount:openshift:bcdevops-admin --namespace=vr5evj-tools apply -f temp-vr5evj-tools.json
#oc '--as=system:serviceaccount:openshift:bcdevops-admin' delete namespace -l 'name=vr5evj'
#oc '--as=system:serviceaccount:openshift:bcdevops-admin' -n vr5evj-dev get 'RoleBinding,ResourceQuota'


#ocadm -n bcgov policy add-role-to-group 'shared-resource-viewer' system:authenticated
