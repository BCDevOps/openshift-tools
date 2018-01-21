#!/bin/bash
source untag_images_usage.inc
source untag_images_args_check.inc
#echo "Untagging images $IMAGE_NAME"
#echo "$DAYS_TO_KEEP"
cutOffDate=`date -v -${DAYS_TO_KEEP}d +%Y%m%d`
echo "IMAGE NAME:   $IMAGE_NAME"
echo "DAYS TO KEEP: $DAYS_TO_KEEP   (i.e. images created before $cutOffDate will be untagged!)"
echo -n "Parameter values correct? (y/n):"
read PARAM_CONFIRMED
if [[ "$PARAM_CONFIRMED" == "y" || "$PARAM_CONFIRMED" == "Y" ]]
then
  echo "PARAMETERS CONFIRMED!"
else
  exit 1
fi
imageTagList=$(oc get istag | awk '{print $1}')
imageTagPrefix="${IMAGE_NAME}:"
myNoFormat='^[0-9]+$'
for isTag in $imageTagList
do
  if [[ "$isTag" == "${IMAGE_NAME}:"* ]]
  then 
    buildNo=${isTag#$imageTagPrefix}
    if [[ $buildNo =~ $myNoFormat ]] ; then
      imageCreationTime=`oc get istag $isTag -o template --template="{{.metadata.creationTimestamp}}"`
      imageDate=${imageCreationTime%T*}
      imgDate=`echo "$imageDate"|sed 's/\-//g'`
      if [ $imgDate -lt $cutOffDate ]
      then
        echo "UNTAG: $isTag -- created  $imgDate "
        oc tag -d $isTag
      fi
    fi
  fi
done
