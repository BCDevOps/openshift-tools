#!/bin/bash
DC=$(oc get dc | awk  'NR >1 {print $1}')
for x in $DC
do
  if [ $x != ocp-storage-migrator ]
  then
      oc get dc/$x
      cn=$(oc describe dc/$x | grep ClaimName | awk '{print $2}')
      for pvcname in $cn 
      do 
        oc get pvc/$pvcname
        oc export pvc/$pvcname -o yaml --as-template=${pvcname}_old >PVC_$x_$pvcname.yaml
      done 
  else
      echo "This is us"
  fi
  echo "----"
done


##
## oc export pvc mariadb -o yaml  --as-template=mariadb_old  | sed '/^    volumeName/ d' | sed '/  status/ d' | sed -i 
# oc project -q

#oc describe pods|grep deploymentconfig
