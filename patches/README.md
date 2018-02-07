# Extended Build Replacement

The steps below describe how to port build processes in OpenShift that use the now-unavailable "Extended Builds" feature to a functionally equivalent configuration.

# What are Extended Builds?

Extended Builds were a feature available in OpenShift up to and including version 3.6.

Extended Builds were a mechanism to "overlay" the output from one build into an existing image, where the build of the initial image *and* instruction for the "overlay" were defined in a single Build Configuration.

The most common use case is where an application's build-time requirements are different than its runtime requirements.    

Extended Builds are no longer supported, but there are alternative ways to achieve the same functionality via "Chained Builds".  This document describes the process of migrating from using Extended Builds to Chained Builds.   

## Patches/Missing Resources Available for Projects

We have created patches/missing resources for gov projects that have used Extended Builds. These are located in the `output` directory of this repo, under the project name and name of the build config requiring fixing.

The sections below describe the steps required to complete the changes.    

## Create a new Build Configuration

First, we need to create a *new* Build Configuration that will perform the work previously done as one of the stages of the Extended Build.

In the most common use of Extended Builds (`bcgov/angular-scaffold`), the needed Build Configuration will use a nodejs image to execute the angular build steps. In output/<project name>/<build config name>, you'll see a file called `angular-app-bc.json`. You'll use this file to create a new build config as follows:

```bash
cd output/<project name>/<build config name> 
oc create -f  angular-app-bc.json -n <project name>
```

After creating this Build config, you should run it to make sure that it works as expected.   

Reminder: you should store the angular-app-bc.json alongside your code in GitHub in the openshift directory.   

## Patch your existing Build Configuration that uses Extended Builds

Next, we need to change your existing Build Configuration so it no longer attempts to use Extended Builds syntax.  This can be done manually or via a "patched" build configuration in output/<project name>/<build config name> and will be called something like <build-config-name>-patched.json.  There will also be a backup of the existing buildconfig. To apply the  patched build config (which will replace the existing one), do the following: 

The existing Build Configuration that is leveraging Extended Builds will have a section that looks like:

```json
 
```

*Note:* You should check the content above to ensure that it matches the image stream names you are using, etc.  Assuming it does, the following command will apply the change in a single shot (backing up the current BuildConfig first).  If the image stream names don't line pup with your project, adjust in the command below as appropriate prior to running the command. 

``` 
oc export bc/angular-on-nginx-build -o json > angular-on-nginx-build-backup.json
 oc patch bc/angular-on-nginx-build --patch='{  "spec": {    "source": {      "type": "Dockerfile",      "dockerfile": "FROM nginx-runtime:latest\nCOPY * /tmp/app/dist/\nCMD  /usr/libexec/s2i/run",      "images": [        {          "from": {            "kind": "ImageStreamTag",            "name": "angular-app-build:latest"          },          "paths": [            {              "sourcePath": "/opt/app-root/src/dist/.",              "destinationDir": "tmp"            }          ]        }      ]    },    "strategy": {      "type": "Docker",      "dockerStrategy": {        "from": {          "kind": "ImageStreamTag",          "namespace": "openshift",          "name": "nginx-runtime:latest"        }      }    }  }}'
```

Once you've executed the above, you should run the angular-on-nginx build, tag it for deployment (e.g `oc tag angular-on-nginx:latest angular-on-nginx:dev ), and confirm it deploys and functions as expected.

If you encouter problems with the patched build config, you can revert to the prior version using the backup you created above.  

## Update Jenkinsfile to trigger *both* builds in turn

Because we now have 2 Build Configurations involved in building our deployable image, we need to update our Jenkinsfile to trigger both in turn, starting with the `angular-app-build`.

Your current Jenkinsfile will require a number of edits...

* Change the top part of the file to look like:

```

// EDIT LINE BELOW (Set APP_NAME to match the "base" name (name without "-build")of the new build config you created in the first step above.) 

// Edit your app's name below 
def APP_NAME = 'angular-app'

// Edit your environment TAG names below
def TAG_NAMES = ['dev', 'test', 'prod']

// You shouldn't have to edit these if you're following the conventions
def BUILD_CONFIG = APP_NAME + '-build'

//EDIT LINE BELOW (Change `IMAGESTREAM_NAME` so it matches the name of your *output*/deployable image stream.) 
def IMAGESTREAM_NAME = 'angular-on-nginx'

// you'll need to change this to point to your application component's folder within your repository
def CONTEXT_DIRECTORY = 'tob-web'


// EDIT LINE BELOW (Add a reference to the CHAINED_BUILD_CONFIG)
def CHAINED_BUILD_CONFIG = 'angular-on-nginx-build'
...

```

* Next, make an edit so your `stage('build ' + BUILD_CONFIG) {` section looks like:

```
stage('build ' + BUILD_CONFIG) {
 echo "Building: " + BUILD_CONFIG
 openshiftBuild bldCfg: BUILD_CONFIG, showBuildLogs: 'true'

 // the CHAINED_BUILD_CONFIG should be triggered when the above build completes, but it doesn't seem to be, so we trigger it explicitly.
 openshiftBuild bldCfg: CHAINED_BUILD_CONFIG, showBuildLogs: 'true'
...
```
