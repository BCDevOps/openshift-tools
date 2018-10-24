#!/usr/bin/env bash

#todo check for user - it's a required value
USER=$1

#todo add optional parameters for role and project

echo "User to remove is ${USER}..."

PROJECTS=$(oc get rolebindings --all-namespaces --no-headers -o wide | grep $USER | awk '{print $1}')

for PROJECT in ${PROJECTS[@]};
    do
        ROLE=$(oc get rolebindings -n ${PROJECT} --no-headers -o wide | grep $USER | awk '{print $2}')
        ROLE=${ROLE:1}
        echo "Removing ${USER} from ${PROJECT} in role ${ROLE}"...
        read -n1 -r -p "Press any key to continue..." key
        oc policy remove-role-from-user ${ROLE} ${USER} -n ${PROJECT}
    done


