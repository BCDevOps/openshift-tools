OpenShift Docker Config Update
===================
This playbook can be used to gracefully restart docker on all nodes across an
ocp cluster after changing docker config options.

Requirements
------------
oc binary on the control node
  - https://www.openshift.org/download.html
  - system:admin or cluster-admin privileges logged in from control node

Ansible 2.0+


Role Variables
--------------

Dependencies
------------

None

