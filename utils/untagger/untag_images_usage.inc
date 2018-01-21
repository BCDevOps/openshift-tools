usage() {
cat <<EOF
UNTAG IMAGES
---------------------------------------------------------------------------
Usage:
  ${0} [-h] -i <image-name> -d <days_to_keep> 
  OPTIONS:
  ========
    -i <image-name> the name of the image (oc get is <image-name>)
    -d <days_to_keep> the number of days from now for which images are kept. i=Images older will be untagged
    -h prints the usage for the script
EOF
exit 1
}
