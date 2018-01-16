usage() {
cat <<EOF
Move PVC
---------------------------------------------------------------------------
Usage:
  ${0} [-h -v -y] -p <project_namespace> -dc <deploy_config> -s <pvc_size> -pvc <pvc_name> -npvc <new_pvc_name> -vol <volume_name> -path <mount_path> -mode <access_mode> -class <storage_class>
  OPTIONS:
  ========
    -p <project_namespace> the namespace for the project
    -dc <deploy_config> nme of the deploymnet config
    -pvc <pvc_name> name of pvc to be moved/extended
    -npvc <new_pvc_name> name of the new/destintion pvc
    -vol <volume_name> name of the colume
    -path <mount_path> volume mount path
    -mode <access_mode> pvc access mode [values: RWO,RWX,ROX]
    -class <storage_class> type of storage [values: gluster-block, gluster-file]
    -s <pvc_size> Size of new pvc in GiB
    -h prints the usage for the script
    -v run the script in verbose mode
    -y do not request parameter confirmation
EOF
exit 1
}
