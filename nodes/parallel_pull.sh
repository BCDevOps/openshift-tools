#!/bin/bash
# Update node config to enable parallel image pulls for an existing installation. 
date=`date +%y%m%d%H%M`
cp /etc/origin/node/node-config.yaml /etc/origin/node/node-config.yaml.$date
cat <<EOF > /~/kublet_parallel_pull.txt
  serialize-image-pulls:
  - "false"
EOF
sed -i '/kubeletArguments/r /~/kublet_parallel_pull.txt' /etc/origin/node/node-config.yaml
systemctl restart atomic-openshift-node
