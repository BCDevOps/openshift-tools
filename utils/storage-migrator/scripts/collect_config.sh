#!/bin/bash
DC=$(oc get dc | awk  'NR >1 {print $1}')
for x in $DC
do
  if [ $x != ocp-storage-migrator ]
  then
      oc get dc/$x
  else
      echo "This is us"
  fi
done


##
# oc project -q
## oc export pvc mariadb -o yaml  --as-template=mariadb_old  | sed '/^    volumeName/ d' | sed '/  status/ d' | sed -i 
