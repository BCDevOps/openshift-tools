# Deploy minio object storage server in OpenShift

## What is minio?

Minio is an Amazon S3 compatible object storage server.  

Learn more here: https://minio.io/

## How-to

The steps below describe how to deploy an instance of minio in one or more project in OpenShift.

### Pre-requisites

* a `minio` ImageStream should exist in the `openshift` namespace in your OpenShift cluster.
* the namespace where you plan to deploy minio should have `image-puller` permissions on the namespace where you are creating your "intermediate" minio image stream (generally your "-tools" namespace).

### Create a "project-level" minio imagestream

In order to provide you with project-level control over promotion of minio versions across your deployment environments, we recommend that you create an imagestream in your project's "-tools" environment, and ImageStreamTagS corresponding to each of your deployment envirionments.  An example of doing this is below:

```bash
oc project <your tools project>
oc tag --alias openshift/minio:stable minio:stable # cross-project aliases like this don't seem to work ATM, but maybe one day...in the meantime, you'll need to update/re-tag periodically   
oc tag --alias minio:stable minio:dev # use of --alias here is so dev will always be updated when stable is updated; omit --alias or use --reference if you prefer not to have this 
oc tag --reference minio:stable minio:test  # use of reference here is so you *have* to explicitly tag in order to affect test
oc tag --reference minio:stable minio:prod # use of reference here is so you *have* to explicitly tag in order to affect prod
```

*Note:* there are other ways to configure your image streams.  The above is one possible strategy, but it gives you a good level of control so you know what version of your image is in what environment. 

### Deploy minio using an OpenShift template

To deploy minio into a deployment project, use the template that exists in the global OpenShift catalog, as below, substituting one of the tags you created above as the value for the `IMAGESTREAM_TAG` parameter:

```bash
oc process minio-deployment -p IMAGESTREAM_NAMESPACE=devex-mpf-secure-tools -p IMAGESTREAM_TAG=<dev|test|prod> | oc create -n <your deployment project> -f -
``` 

   
