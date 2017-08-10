# Purpose
This playbook is is intended to perform an automated *graceful* restart
of all openshift components ( masters, infrastructure nodes, application nodes).

Note: Additional work must be performed to ensure certain apps are highly
available by running multiple pods with node anti-affinity configurations.

This playbook simply works in this order:
1. Restart each master node, one at a time
2. Restart each infrastructure node, one at a time, waiting for a router
to be running on the restarted node before moving on
3. Restart each app node, one at a time

# Requirements
*ocp_inventory* should be updated to reflect the appropriate environment.

# Inventory
The playbook assumes an inventory similar to that of ocp_inventory and can
be used to target any set of nodes.
