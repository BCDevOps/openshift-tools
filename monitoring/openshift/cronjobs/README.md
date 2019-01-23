# Cluster Pruning jobs

## Object Requirements

* BuildConfig - job-runner
* cronjob - ${JOB_NAME}
* serviceAccount: ${JOB_SERVICE_ACCOUNT}
* RBAC: ClusterRoleBinding for cluster-admin to ${JOB_SERVICE_ACCOUNT}
* PVC (RWX) for storing logs long term - ${JOB_PERSISTENT_STORAGE_NAME}

## Soft Pruning

Performs a cluster prune of builds, deployments, and images before a rollout of the image registry (on completed image prune).  This job will also log to both pod output and a pre-defined PVC for long term log retention.

## Hard Pruning

Switches the registry to Read-Only mode before connecting to one of the active docker-registry pods and running a
docker prune to remove any unreferenced image blocks.  Once this is completed, it will switch the registry back to normal operation.

## Log Rotation

Runs a `find` command on the logging PVC to delete old logs.

## Setup

1. Create Persistent Storage (as RWX)
2. Edit Parameters section of each pruning job with appropriate changes:

* [vars-registry-soft-prune.yaml](vars-registry-soft-prune.yaml)
* [vars-registry-hard-prune.yaml](vars-registry-hard-prune.yaml)
* [vars-log-rotation.yaml](vars-log-rotation.yaml)

3. Run the included bash script that processes and creates the required objects.

    ```bash
    create-cron.sh
    ```

4. Add the `system:image-pruner` role. The service account used to run the registry instances requires additional permissions in order to list some resources.

    Get the service account name:

    ```bash
    service_account=$(oc get -n default \
        -o jsonpath=$'system:serviceaccount:{.metadata.namespace}:{.spec.template.spec.serviceAccountName}\n' \
        dc/docker-registry)
    oc adm policy add-cluster-role-to-user \
        system:image-pruner ${service_account}
    ```

5. Start the image build.

  ```bash
  oc start-build job-runner
  oc logs -f bc/job-runner
  ```

Cron run-logs are available in the pod logs as well as compressed within the PVC.

`Maximum number of failed pods is ${FAILED_JOBS_HISTORY_LIMIT} * ${JOB_BACKOFF_LIMIT}`

## How this works

We build an image from `openshift3/ose-cli` and include several BASH scripts. 

One of the scripts `job-runner` provides logging and error handling. It is set as the ENTRYPOINT of the image and indented to run as PID 1 and trap any graceful shutdown requests due to pod deletion or job timeout. `job-runner` will then run the arg passed in to the pod config and log its output. On a successful run, the log will be compressed.

BASH scripts for individual cron purposes also include logic to handle a graceful shutdown and clean up properly.

## Outstanding

* create cronjob success/fail monitoring and alert on last failure.

## Testing

Cronjobs can be tested by creating a job immediately based on the cronjob spec. This is simpler than trying to keep updating the schedule of the cronjob to be just in the future.

```bash
oc create job cronjob-registry-soft-prune-1 --from=cronjob/cronjob-registry-soft-prune
```
