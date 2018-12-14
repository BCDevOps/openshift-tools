# Cluster Pruning jobs

## Soft Pruning

Performs a cluster prune of builds, deployments, and images before a rollout of the image registry (on completed image prune).  This job will also log to both pod output and a pre-defined PVC for long term log retention.

### Object Requirements

* configmap - ${JOB_SOURCE_SCRIPT}
* cronjob - ${JOB_NAME}
* serviceAccount: ${JOB_SERVICE_ACCOUNT}
* RBAC: ClusterRoleBinding for cluster-admin to ${JOB_SERVICE_ACCOUNT}
* PVC (RWX) for storing logs long term - ${JOB_PERSISTENT_STORAGE_NAME}

## Hard Pruning

Switches the registry to Read-Only mode before connecting to one of the active docker-registry pods and running a
docker prune to remove any unreferenced image blocks.  Once this is completed, it will switch the registry back to normal operation.

## Setup

1. Create Persistent Storage (as RWX)
2. Edit Parameters section of each pruning job with appropriate changes:

* [vars-registry-soft-prune.yaml](vars-registry-soft-prune.yaml)
* [vars-registry-hard-prune.yaml](vars-registry-hard-prune.yaml)

3. Run the included bash script that processes and creates the required objects.

```bash
create-cron.sh
```

Cron run-logs are available in the pod logs as well as compressed within the PVC.

`Maximum number of failed pods is ${FAILED_JOBS_HISTORY_LIMIT} * ${JOB_BACKOFF_LIMIT}`

### Outstanding

* create cronjob success/fail monitoring and alert on last failure.