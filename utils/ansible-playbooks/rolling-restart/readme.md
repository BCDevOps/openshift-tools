OpenShift Rolling-Restart
===================
This playbook can be used to gracefully restart all nodes across an
ocp cluster. It also can be used to upgrade the host operating system by
setting yum_update=yes (though this requires appropriate access to valid
content).

Note: If the control node is a master server, exclude it from the inventory
and perform the tasks manually on that node. It is best to run this playbook
from an external control node.

Requirements
------------
oc binary on the control node
  - https://www.openshift.org/download.html
  - system:admin or cluster-admin privileges logged in from control node

Ansible 2.0+


Role Variables
--------------

yum_update=no (default) - set to yes to upgrade the host os packages

Dependencies
------------

None



Author Information
------------------

Arctiq Inc. (dev@arctiq.ca)
