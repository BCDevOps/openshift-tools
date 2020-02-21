# DellEMC ElasticCloudStorage S3 Operator for OpenShift

Provisioning S3 bucket/user within an ECS service and creating an Object Bucket Claim (OBC) set of objects for OpenShift projects.

## Environment requirements

- access to an ECS service
  - <https://github.com/EMCECS/ECS-CommunityEdition> is a free version you can self host
  - <https://portal.ecstestdrive.com> may work (untested)
- access to an OpenShift cluster
  - cluster admin is required for the operator installation and setup

## Variable Setup

Set the following environment variables before you begin:

``` bash
export ECS_ADMIN=[admin username]
export ECS_ADMIN_TOKEN=[admin token]
```

Set ansible vars.yml contents:

``` yaml
## Target ECS URLs
objstore_admin_url: "https://[ECS Admin URL]:4443"
objstore_s3_url: "https://[ECS S3 URL]"
objstore_namespace: "[Your Namespace]"

OBC_name: test2
OBC_project: jeff-tools
OBC_type: platform
```

run the playbook:

``` bash
ansible-playbook ecs_bucket.yaml -e action="[provision|deprovision]"
```

Next Steps: Create secret and configmap
