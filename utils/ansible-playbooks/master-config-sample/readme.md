#Purpose
This folder provides some sample playbooks that can be used to edit the
/etc/origin/master/master-config.yaml on all masters and restarts services.

Note: Testing should be performed in a lab environment or on sample files
prior to utilizing in production.

#Description
## enable-audit-sample
This file allows the user to create a short playbook to enable the audit
feature for user action auditing. The example reles on a sample inventory
file called *node_list* that has a group called *[masters]* which identifies
all master nodes.

Note: The blockinfile module uses markers to understand where to operate in
the file. You must use a custom marker for each differing segment of code to
avoid undesired overwrites. 
