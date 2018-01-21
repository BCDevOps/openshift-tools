while getopts i:d:h FLAG; do
  case $FLAG in
    i ) IMAGE_NAME=$OPTARG ;;
    d ) DAYS_TO_KEEP=$OPTARG ;;
    h ) usage ;;
    \? ) usage ;;
    * ) #unrecognized option - show help
      echo -e \\n"$FLAG - Invalid script option"\\n
      usage
      ;;
  esac
done

#
# IMAGE NAME
#
# Check if image name is valid
if [ -z ${IMAGE_NAME+x} ]
then
  echo -n "Enter the name of the image: "
  read IMAGE_NAME
fi
if [ ${#IMAGE_NAME} -lt 1 ]
then
  echo "ERROR: No image name provided!"
  exit 1
fi 
isName=`oc get is ${IMAGE_NAME} | awk '/${IMAGE_NAME}/ {print $1}'`
if [ $? -gt 0 ]
then
  echo "ERROR: No image with name $PROJECT_NAMESPACE"
  exit 1
fi
if [ ! $isName == "$IMAGE_NAME" ]
then
  echo "ERROR: No image with name $IMAGE_NAME"
  exit 1
fi

#
# NO OF DAY IMAGES TO KEEP
# 
if [ -z ${DAYS_TO_KEEP+x} ]
then
  echo -n "Enter the number of days for which images are kept:"
  read DAYS_TO_KEEP
fi
myDaysFormat='^[0-9]+$'
if ! [[ $DAYS_TO_KEEP =~ $myDaysFormat ]] ; then
  echo "ERROR: Invalid format. Sorry integers only"
  exit 1
fi
if [ $DAYS_TO_KEEP -lt 1 ] 
then
  echo "Min number of days to keep is 14 days."
  DAYS_TO_KEEP=14
fi
