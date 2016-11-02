#OpenShift Persistent Volume utility scripts
 
 ##To create a new set of Persistent Volumes
 
 Assuming that one or more new backend storage (Gluster) volumes/shares has been provisioned, the `pv_create.sh` script can be used to create the required Persistent Volume (PV) resources in OpenShift to allow the storage to be utilized by applications via PersistentVolumeClaims.
 
 To use pv_create.sh
 
 - create a text file containing the paths of the Gluster volumes/shares, one per line
 - if necessary, update 

