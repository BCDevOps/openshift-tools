# OSE PV Refresh Script for NFS and GlusterFS.
# Prepared by: Shah Zobair, szobair@redhat.com
# Updated by: shea.stewart@arctiq.ca to mount and remove content on refresh volumes. 

/usr/bin/oc get pv | egrep -i "Failed" | cut -f1 -d" " > /tmp/pv_refresh

for pv in `cat /tmp/pv_refresh`; do
EndpointIP = 1.1.1.1 #Update endpoint IP
Name=`/usr/bin/oc describe pv $pv | grep "^Name:" | awk '{print $2}'`
ReclaimPolicy=`/usr/bin/oc describe pv $pv | grep "Reclaim Policy:" | awk '{print $3}'`
AccessModes=`/usr/bin/oc describe pv $pv | grep "Access Modes:" | awk '{print $3}'`
Capacity=`/usr/bin/oc describe pv $pv | grep "Capacity:" | awk '{print $2}'`
Type=`/usr/bin/oc describe pv $pv | grep "Type:" | awk '{print $2}'`
Path=`/usr/bin/oc describe pv $pv | grep "Path:" | awk '{print $2}'`
ReadOnly=`/usr/bin/oc describe pv $pv | grep "ReadOnly:" | awk '{print $2}'`

if [[ $Type == "Glusterfs" ]]; then
EndpointsName=`/usr/bin/oc describe pv $pv | grep "EndpointsName:" | awk '{print $2}'`
else
Server=`/usr/bin/oc describe pv $pv | grep "Server:" | awk '{print $2}'`
fi

if [[ $AccessModes == "RWO" ]]; then
AccessModes="ReadWriteOnce"
elif [[ $AccessModes == "RWX"  ]]; then
AccessModes="ReadWriteMany"
else
AccessModes="ReadOnlyMany"
fi

if [[ $Type == "Glusterfs" ]]; then

cat << EOF > /tmp/pv_create.yaml
apiVersion: "v1"
kind: "PersistentVolume"
metadata:
  name: "$Name"
spec:
  capacity:
    storage: "$Capacity"
  accessModes:
    - "$AccessModes"
  glusterfs:
    endpoints: "$EndpointsName"
    path: "$Path"
    readOnly: $ReadOnly
  persistentVolumeReclaimPolicy: "$ReclaimPolicy"
EOF

else

cat << EOF > /tmp/pv_create.yaml
apiVersion: "v1"
kind: "PersistentVolume"
metadata:
  name: "$Name"
spec:
  capacity:
    storage: "$Capacity"
  accessModes:
    - "$AccessModes"
  nfs:
    path: "$Path"
    server: "$Server"
    readOnly: $ReadOnly
  persistentVolumeReclaimPolicy: "$ReclaimPolicy"
EOF



fi

/usr/bin/oc delete pv $pv


if [[ $ReclaimPolicy == "Recycle" ]]; then 
mount -t glusterfs $EndpointIP:$Path /mnt/glusterfstmp
echo "`date` Failed PV Found ($pv) with data and refreshed" >> /var/log/pv_refresh_recycle.log
ls -lha /mnt/glusterfstmp >> /var/log/pv_refresh_recycle.log 
rm -rf /mnt/glusterfstmp/*
umount /mnt/glusterfstmp
fi

/usr/bin/oc create -f /tmp/pv_create.yaml -n openshift

echo "`date` Failed PV Found ($pv) and refreshed" >> /var/log/pv_refresh.log
cat /tmp/pv_create.yaml >> /var/log/pv_refresh.log
echo "#######" >> /var/log/pv_refresh.log
echo "" /var/log/pv_refresh.log 

done
