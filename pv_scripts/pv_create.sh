#!/bin/bash

# Create a list of export names in pv_list and run this script to create all yaml files and pv objects.
# In this case, exports are created with a trailing 'G', which is converted to 'g' for compatibility when creating the pv objects
# Created by shea.stewart@arctiq.ca

ENDPOINT=glusterfs-cluster-app
for i in $(cat pv_list)
do
SIZE=$(echo ${i} | awk -F"-" '{print $4}')
SIZE=$(echo ${SIZE} | sed 's/G//')
LEN=${#i}
NAME=${i:0:$LEN-1}g
cat << EOF > ${i}.yaml
apiVersion: "v1"
kind: "PersistentVolume"
metadata:
  name: ${NAME}
spec:
  capacity:
    storage: ${SIZE}Gi
  accessModes:
  - ReadWriteOnce
  glusterfs:
    endpoints: ${ENDPOINT}
    path: "/${i}"
    readOnly: false
  persistentVolumeReclaimPolicy: "Recycle"
EOF
oc create -f ${i}.yaml
done
