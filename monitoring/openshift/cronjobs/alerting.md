# Building Graphana alerts

The following prometheus query will grab the last started job_name for each cronjobs with a label named "cronjob", and then check the failure status (0 - no failure, !0 - failure).

``` sql
clamp_max(
  max(
    kube_job_status_start_time
    * ON(job_name) GROUP_RIGHT()
    kube_job_labels{label_cronjob!=""}
  ) BY (job_name, label_cronjob)
  == ON(label_cronjob) GROUP_LEFT()
  max(
    kube_job_status_start_time
    * ON(job_name) GROUP_RIGHT()
    kube_job_labels{label_cronjob!=""}
  ) BY (label_cronjob),
1)
* ON(job) GROUP_LEFT()
  (kube_job_status_failed),
```

An exported graphana dashboard can be found here: [alerts-cronjobs-graphana.json](alerts-cronjobs-graphana.json)