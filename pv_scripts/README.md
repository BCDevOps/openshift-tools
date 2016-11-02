#OpenShift Persistent Volume utility scripts
 
 ##To create a new set of Persistent Volumes
 
 Assuming that one or more new backend storage (Gluster) volumes/shares has been provisioned, the `pv_create.sh` script can be used to create the required Persistent Volume (PV) resources in OpenShift to allow the storage to be utilized by applications via PersistentVolumeClaims.
 
 To use pv_create.sh
 
 - create a text file called pv_list in the same directory as pv_create, containing the paths of the Gluster volumes/shares, one per line
 - run the script; it will create a PV for each of the entries in the pv_list file and output the results of the pv creation operations as they complete. 

