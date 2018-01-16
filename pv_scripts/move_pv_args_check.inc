DEBUG=0
CONFIRM=1

while getopts p:pvc:npvc:dc:vol:path:mode:class:s:v:y:h FLAG; do
  case $FLAG in
    p ) PROJECT_NAMESPACE=$OPTARG ;;
    dc ) DEPLOY_CONFIG=$OPTARG ;;
    vol ) VOLUME_NAME=$OPTARG ;;
    path ) MOUNT_PATH=$OPTARG ;;
    mode ) ACCESS_MODE=$OPTARG ;;
    class ) STORAGE_CLASS=$OPTARG ;;
    pvc ) PVC_NAME=$OPTARG ;;
    npvc ) PVC_NAME_NEW=$OPTARG ;;
    s ) PVC_SIZE_NEW=$OPTARG ;;
    v ) export DEBUG=1 ;;
    y ) export CONFIRM=0 ;;
    h ) usage ;;
    \? ) usage ;;
    * ) #unrecognized option - show help
      echo -e \\n"Invalid script option"\\n
      usage
      ;;
  esac
done

# PROJECT
#
# Check if project parameter is set
if [ -z ${PROJECT_NAMESPACE+x} ]
then
  echo -n "Enter the name of the project: "
  read PROJECT_NAMESPACE
fi
if [ ${#PROJECT_NAMESPACE} -lt 1 ]
then
  echo "ERROR: No project name provided!"
  exit 1
fi 
# Switch to project namespace
oc project $PROJECT_NAMESPACE &> /dev/null
if [ $? -gt 0 ]
then
  echo "ERROR: No projet with name $PROJECT_NAMESPACE"
  exit 1
fi
myProject=`oc project`
if [[ ! $myProject == *"$PROJECT_NAMESPACE"* ]]; then
  echo "ERROR: No projet with name $PROJECT_NAMESPACE"
  exit 1
fi

#PVC 
#
if [ -z ${PVC_NAME+x} ]
then
  echo -n "Enter the name of the pvc to move/expand: "
  read PVC_NAME
fi
if [ ${#PVC_NAME} -lt 1 ]
then
  echo "ERROR: No pvc name provided!"
  exit 1
fi 
if [ -z ${PVC_SIZE+x} ]
then
  echo -n "Enter the size of the new pvc: "
  read PVC_SIZE
fi
if [ "$PVC_SIZE" -eq "$PVC_SIZE" ]
then
    echo "Sorry integers only"
    exit 1
else 
    if [ $PVC_SIZE -gt 200 ] 
    then
      echo "Max PVC size is 200!"
      exit 1
    fi
    if [ $PVC_SIZE -lt 1 ] 
    then
      echo "Min PVC size is 1, using 1GiB."
      PVC_SIZE=1
    fi
fi

# Check pvc (old one exists, new one does not exist)
pvcOK=0
pvc_list=$(oc get pvc | awk 'NR>1 {print $1}')
for p in $pvc_list
do
  if [ "$p" == "$PVC_NAME" ]
  then 
    pvcOK=1
  fi
  if [ "$p" == "$PVC_NAME_NEW" ]
  then 
    echo "ERROR: $PVC_NAME_NEW alredy exists!"
    exit 1
  fi
done
if [ $pvcOK -lt 1 ] 
then
  echo "ERROR: No pvc $PVC_NAME exists!"
  exit 1
fi

dcOK=0
if [ -z ${DEPLOY_CONFIG+x} ]
then
  echo -n "Enter the name of the deploy config: "
  read DEPLOY_CONFIG
fi
if [ ${#DEPLOY_CONFIG} -lt 1 ]
then
  echo "ERROR: No deployment config name provided!"
  exit 1
fi 
deploys=$(oc get dc|awk 'NR>1 {print $1}')
for d in deploys 
do
  if [ "$d" == "$DEPLOY_CONFIG" ] 
  then
    dcOK=1
  fi
done
if [ $dcOK -lt 1 ] 
then
  echo "ERROR: No dc $DEPLOY_CONFIG exists!"
  exit 1
fi

#VOLUME_NAME
if [ -z ${VOLUME_NAME+x} ]
then
  echo -n "Enter the volume name for the pvc: "
  read VOLUME_NAME
fi
if [ ${#VOLUME_NAME} -lt 1 ]
then
  echo "ERROR: No volume name provided!"
  exit 1
fi 

#MOUNT_PATH
if [ -z ${MOUNT_PATH+x} ]
then
  echo -n "Enter the mount path for the pvc: "
  read MOUNT_PATH
fi
if [ ${#MOUNT_PATH} -lt 1 ]
then
  echo "ERROR: No mount path provided!"
  exit 1
fi 

# ACCESS_MODE
if [ -z ${ACCESS_MODE+x} ]
then
  echo -n "Enter the access mode for the pvc: "
  read ACCESS_MODE
fi
if [ ${#ACCESS_MODE} -lt 1 ]
then
  echo "ERROR: No access mode provided!"
  exit 1
fi 
accessModeOK=0
case $ACCESS_MODE in
    ReadWriteOnce|ReadOnlyMany|ReadWriteMany) accessModeOK=1;;
    RWO|RWX|ROX) accessModeOK=1;;
    *)           accessModeOK=0;;
esac
if [ $accessModeOK -lt 1 ] 
then
  echo "ERROR: Invalid access mode! Valid values: RWO, RWX, ROX"
  echo "       ReadWriteOnce(RWO),ReadOnlyMany(ROX),ReadWriteMany(RWX)"
  exit 1
fi

#STORAGE_CLASS
if [ -z ${STORAGE_CLASS+x} ]
then
  echo -n "Enter the storage class for the pvc: "
  read STORAGE_CLASS
fi
if [ ${#STORAGE_CLASS} -lt 1 ]
then
  echo "ERROR: No storage class provided!"
  exit 1
fi 
storageClassOK=0
case $STORAGE_CLASS in
    gluster-block|gluster-file) storageClassOK=1;;
    *)                          storageClassOK=0;;
esac
if [ $storageClassOK -lt 1 ] 
then
  echo "ERROR: Invalid storage class! Valid values: gluster-block, gluster-file"
  exit 1
fi
