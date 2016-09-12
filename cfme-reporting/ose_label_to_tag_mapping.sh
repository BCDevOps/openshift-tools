## This script runs the temporary label mapping code and restarts EVM services, executed by cron daily. This is a workaround until label reporting is integrated in future CFME versions. 
#!/bin/bash

## Update latest map-labels-to-tags.rb from github (https://github.com/BCDevOps/openshift-tools.git)
cd /root/git/openshift-tools
git pull

##Move to the correct VMDB path with the correct rails version
cd /var/www/miq/vmdb
bundle exec rails runner ~/git/openshift-tools/cfme-reporting/map-labels-to-tags.rb

## Restart CFME services
systemctl restart evmserverd
