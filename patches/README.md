# Extended Build Replacement

The steps below describe how to port build processes in OpenShift that use the now-unavailable "Extended Builds" feature to a functionally equivalent configuration.

# What are Extended Builds?

Extended Builds were a feature available in OpenShift up to and including version 3.6.

Extended Builds were a mechanism to "overlay" the output from one build into an existing image, where the build of the initial image *and* instruction for the "overlay" were defined in a single Build Configuration.

The most common use case is where an application's build-time requirements are different than its runtime requirements.    

Extended Builds are no longer supported, but there are alternative ways to achieve the same functionality via "Chained Builds".  This document describes the process of migrating from using Extended Builds to Chained Builds.   

## Create a new Build Configuration

First, we need to create a *new* Build Configuration that will perform the work previously done as one of the stages of the Extended Build.

In the most common use of Extended Builds (`bcgov/angular-scaffold`), the needed Build Configuration will use a nodejs image to exectue the angular build steps. This build configuration can be created using the following command while "in" your `-tools` project, and adapting the parameter values for your project layout:

```bash
oc process https://cdn.rawgit.com/bcgov/angular-scaffold/515fd8e5/openshift/templates/angular-app/angular-app.json -p NAME=<name> -p GIT_REPO_URL=<your_repo> -p GIT_REF=<branch> -p SOURCE_CONTEXT_DIR=<contex_dir> | oc create -f - 
```

After creating this Build config, you should run it to make sure that it works as expected.   

Note: you should capture the resulting BuildConfiguration and store alongside your code in GitHub.   

## Patch your existing Build Configuration that uses Extended Builds

Next, we need to change your existing Build Configuration so it no longer attempts to use Extended Builds syntax.  This can be done manually or via `oc patch`.

The existing Build Configuration that is leveraging Extended Builds will have a section that looks like:

```json
...
 "spec": {
    "triggers": [
      {
        "type": "ImageChange",
        "imageChange": {}
      }
    ],
    "runPolicy": "Parallel",
    "source": {
      "type": "Git",
      "git": {
        "uri": "https://github.com/bcgov/yourrepo.git",
        "ref": "1.3"
      }
    },
    "strategy": {
      "type": "Source",
      "sourceStrategy": {
        "from": {
          "kind": "ImageStreamTag",
          "name": "angular-builder:latest"
        },
        "runtimeImage": {
          "kind": "ImageStreamTag",
          "name": "nginx-runtime:latest"
        },
        "runtimeArtifacts": [
          {
            "sourcePath": "/opt/app-root/src/dist/",
            "destinationDir": "tmp/app"
          }
        ]
      }
    }
...
```

It needs to be updated to look like:

```json
...
  "spec": {
    "triggers": [
      {
        "type": "ImageChange",
        "imageChange": {}
      }
    ],
    "runPolicy": "Parallel",
    "source": {
      "type": "Dockerfile",
      "dockerfile": "FROM nginx-runtime:latest\nCOPY * /tmp/app/dist/\nCMD  /usr/libexec/s2i/run",
      "images": [
        {
          "from": {
            "kind": "ImageStreamTag",
            "name": "angular-app-build:latest"
          },
          "paths": [
            {
              "sourcePath": "/opt/app-root/src/dist/.",
              "destinationDir": "tmp"
            }
          ]
        }
      ]
    },
    "strategy": {
      "type": "Docker",
      "dockerStrategy": {
        "from": {
          "kind": "ImageStreamTag",
          "namespace": "openshift",
          "name": "nginx-runtime:latest"
        }
      }
    }
...
```

*Note:* You should check the content above to ensure that it matches the image stream names you are using, etc.  Assuming it does, the following command will apply the change in a single shot.  If the image stream names don't line pup with your project, adjust in the command below as appropriate prior to running the command. 

``` 
 oc patch bc/angular-on-nginx-build --patch='{  "spec": {    "source": {      "type": "Dockerfile",      "dockerfile": "FROM nginx-runtime:latest\nCOPY * /tmp/app/dist/\nCMD  /usr/libexec/s2i/run",      "images": [        {          "from": {            "kind": "ImageStreamTag",            "name": "angular-app-build:latest"          },          "paths": [            {              "sourcePath": "/opt/app-root/src/dist/.",              "destinationDir": "tmp"            }          ]        }      ]    },    "strategy": {      "type": "Docker",      "dockerStrategy": {        "from": {          "kind": "ImageStreamTag",          "namespace": "openshift",          "name": "nginx-runtime:latest"        }      }    }  }}'
```

Once you've executed the above, you should run the angular-on-nginx build, tag it for deployment (e.g `oc tag angular-on-nginx:latest angular-on-nginx:dev ), and confirm it deploys and functions as expected. 

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
