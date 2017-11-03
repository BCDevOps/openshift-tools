# OCP Storage Migrator (Gluster Based)
The purpose of this container is to migrate persistent storage from one
mount to another within a project.

The initial use case behind this is for migrating between traditional
gluster persistent volumes and dynamic gluster volumes with heketi (CNS/CRS).


# Requirements
## Service Account
A service account is required that has the rights to:
- read existing pv and deployment configurations
- patch deployment configs
- execute deployments

For initial tests we will use a service account with administrative rights on
the project.

```
oc create serviceaccount ocp-migrator -n <project_name>
oc adm policy add-role-to-user admin system:serviceaccount:ocp-migrator:ocp-migrator -n <project_name>
```
