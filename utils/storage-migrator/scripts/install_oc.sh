#!/bin/bash
mkdir /opt/oc
cd /opt/oc
wget https://github.com/openshift/origin/releases/download/v3.6.1/openshift-origin-client-tools-v3.6.1-008f2d5-linux-64bit.tar.gz
tar -xvzf openshift-origin-client-tools-v3.6.1-008f2d5-linux-64bit.tar.gz
cp /opt/oc/openshift-origin-client-tools-v3.6.1-008f2d5-linux-64bit/oc /usr/local/bin/
oc version
oc login https://172.30.0.1:443 --token=$TOKEN --insecure-skip-tls-verify=true
