usage() {
cat <<EOF
Move PVC
---------------------------------------------------------------------------
Usage:
  ${0} [-h -y] -p <project_namespace> -d <deploy_config> -s <pvc_size> -S <pvc_name> -D <new_pvc_name> -v <volume_name> -l <mount_path> -m <access_mode> -c <storage_class>
  OPTIONS:
  ========
    -p <project_namespace> the namespace for the project
    -d <deploy_config> nme of the deploymnet config
    -v <volume_name> name of the colume
    -l <mount_path> volume mount path
    -m <access_mode> pvc access mode [values: RWO,RWX,ROX]
    -c <storage_class> type of storage [values: gluster-block, gluster-file]
    -S <pvc_name> name of pvc to be moved/extended
    -D <new_pvc_name> name of the new/destintion pvc
    -s <pvc_size> Size of new pvc in GiB
    -h prints the usage for the script
    -y do not request parameter confirmation
EOF
exit 1
}
