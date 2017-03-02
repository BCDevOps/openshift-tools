#Set up resources in -tools

* The ImageStream for InfluxDB:

`oc create -f influxdb-is.json`

* The ImageStream for Telegraf:

`oc create -f telegraf-is.json`

* The BuildConfig for Grafana:

`oc process -f grafana-build.json | oc create -f -`

#Set up resources in deployment project(s)

* The DeploymentConfig for InfluxDB (setting PERSISTENT_VOLUME_CAPACITY as desired):

`oc process -f influxdb-deploy.json -v PERSISTENT_VOLUME_CAPACITY=1Gi | oc create -f -`

* The DeploymentConfig for Grafana:

`oc process -f grafana-deploy.json -v GRAFANA_SUBDOMAIN=<subdomain> | oc create -f -`

* The ConfigMaps for Telegraf:

```
oc create configmap telegraf-conf --from-file=../telegraf-conf/
oc create configmap metrics-script --from-file=../metrics_scripts/
```

* The DeploymentConfig for Telegraf:

`oc process -f telegraf-deploy.json | oc create -f -`
