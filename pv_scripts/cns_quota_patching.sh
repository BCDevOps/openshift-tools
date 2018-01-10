#!/bin/bash
#
# Patch CNS block/file quotas for all projects
#
for P in $(oc get projects -o name|sed 's#projects/##');
do 
  echo $P; 
  Q=$(oc -n $P get quota -o name);
  if [ -n "$Q" ]
  then
    oc -n $P patch $Q -p '{"spec":{"hard":{"gluster-file.storageclass.storage.k8s.io/persistentvolumeclaims": 10, "gluster-file.storageclass.storage.k8s.io/requests.storage": 200Gi, "gluster-block.storageclass.storage.k8s.io/persistentvolumeclaims": 5, "gluster-block.storageclass.storage.k8s.io/requests.storage": 200Gi}}}';
  fi
done
