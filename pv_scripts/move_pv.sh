#!/bin/bash

# ASSUMPTIONS:
# - container has one volume mount
# - pvc has one access mode

# PARAMETERS:
# PROJECT NAMESPACE: oc project $PROJECT_NAMESPACE
# DEPLOYMENT CONFIGURATION: DEPLOYMENT_CONFIG=oc get dc|awk 'NR>1 {print $1}'
# PVC ACCESS MODE: ACCESS_MODE=oc get pvc/<PVC_NAME> -o template --template="{{.spec.accessModes}}"
# PVC NAME: PVC_NAME=oc get pvc | awk 'NR>1 {print $1}' 
# PVC REQ SIZE: oc get pvc/<PVC_NAME> -o template --template="{{.spec.resources.requests.storage}}"
# PVC ACTUAL SIZE: PVC_SIZE=oc get pvc/<PVC_NAME> -o template --template="{{.status.capacity.storage}}"
# VOLUME NAME: oc get dc/<DEPLOY_CONFIG> -o template --template="{{.spec.template.spec.volumes}}"
# VOLUME MOUNT PATH: oc get dc/<DEPLOY_CONFIG> -o template --template="{{.spec.template.spec.containers}}" or oc volume dc/mysql
# STORAGE_CLASS: storage class of new pvc [gluster_file|gluster_block]
# PVC_NAME_NEW: name of new pvc 

source move_pv_usage.inc
source move_pv_args_check.inc


# Switch to project namespace
oc project $PROJECT_NAMESPACE &> /dev/null
if [ $? -gt 0 ]
then
  echo "ERROR: No projet with name $PROJECT_NAMESPACE"
  exit 1
fi

# get no of current replicas
CURRENT_REPLICA_CNT=`oc get dc/$DEPLOY_CONFIG -o template --template="{{.status.availableReplicas}}"`
if [ ${#CURRENT_REPLICA_CNT} -lt 1 ]
then
  echo "ERROR: Could not retrieve replica count for $DEPLOY_CONFIG!"
  exit 1
fi

echo "PROJECT:        $PROJECT_NAMESPACE"
echo "DEPLOY_CONFIG:  $DEPLOY_CONFIG"
echo "PVC_NAME:       $PVC_NAME"
echo "PVC_NAME_NEW:   $PVC_NAME_NEW"
echo "PVC_SIZE:       $PVC_SIZE"
echo "ACCESS_MODE:    $ACCESS_MODE"
echo "VOLUME_NAME:    $VOLUME_NAME"
echo "MOUNT_PATH:     $MOUNT_PATH"
echo "STORAGE_CLASS:  $STORAGE_CLASS"
if [ $CONFIRM -gt 0 ] 
then
  echo -n "Parameter values correct? (y/n):"
  read PARAM_CONFIRMED
  if [[ "$PARAM_CONFIRMED" == "y" || "$PARAM_CONFIRMED" == "Y" ]]
  then
    echo "PARAMETERS CONFIRMED!"    
  else 
    exit 1
  fi 
fi


# Spawn container for the storage maintenance
oc run pvcmigrator --image=registry.access.redhat.com/rhel7 -- tail -f /dev/null
POD_NAME="NONE"
sleep 15
myPods=$(oc get pods|awk 'NR>1 {print $1}')
for pod in $myPods
do
  if [[ $pod == pvcmigrator* ]]
  then
    if [[ ! $pod == *deploy ]]
    then
      POD_NAME=$pod
    fi
  fi
done
if [ "$POD_NAME" == "NONE" ]
then
  echo "ERROR RHL7 POD for copying PVC content did not start up!"
fi
myPodStatus="none"
for i in `seq 1 10`;
do
  myPodStatus=`oc get pod $POD_NAME | awk 'NR>1 {print $3}'`
  if [ "$myPodStatus" == "Running" ]
  then
    break
  fi
  sleep 5
done
if [ "$POD_NAME" == "NONE" ]
then
  echo "ERROR RHL7 POD for copying PVC content was not created!"
  exit 1
fi
if [ ! "$myPodStatus" == "Running" ]
then
  echo "ERROR RHL7 POD for copying PVC content did not start up!"
  exit 1
fi

# scale down application container accessing pvc
oc scale dc $DEPLOY_CONFIG --replicas=0

# Mount old PVC to that container
oc volume dc/pvcmigrator --add -t pvc --name=$PVC_NAME --claim-name=$PVC_NAME --mount-path=/old${MOUNT_PATH}

# Create and mount new PV/PVC to that container
oc volume dc/pvcmigrator --add -t pvc --name=$PVC_NAME_NEW --claim-name=$PVC_NAME_NEW --mount-path=/new${MOUNT_PATH} --claim-class=$STORAGE_CLASS --claim-mode=$ACCESS_MODE --claim-size=${PVC_SIZE}Gi

# rsh into the container
# Migrate data to the new storage
oc exec $POD_NAME -- df
oc exec $POD_NAME -- ls -alr /new
oc exec $POD_NAME -- ls -alr /old
oc exec $POD_NAME -- cp -Rp  /old${MOUNT_PATH}/ /new${MOUNT_PATH}

# The last step, you need to switch to the new storage volume in <container>:
oc volume dc/$DEPLOY_CONFIG --remove --name=$VOLUME_NAME
oc volume dc/$DEPLOY_CONFIG --add -t pvc --name=$VOLUME_NAME --claim-name=$PVC_NAME_NEW --mount-path=$MOUNT_PATH

# Restart application container
oc scale dc $DEPLOY_CONFIG --replicas=1

# Clean up
#oc scale dc/pvcmigrator --replicas=0
#oc delete  dc pvcmigrator
