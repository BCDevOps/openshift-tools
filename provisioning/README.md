#DevOps Platform Onboarding and Quickstart Tools/Process

This document describes the process/steps and tools involved in onboarding a development team onto the BC Gov DevOps platform.
  
Note that this document serves as both a "step-by-step" and also potentially as a reference for indivudals and teams who may not necessarily be "starting from the start" but need to add something to an existing environment. 
  
The general steps are as follows:
    
* Request Project Set 
* Create Project Set
* Apply starter app
* Populate "Tools" project space with Jenkins and "Skeleton" Pipeline
* Update/Add Pipelines as necessary

Each of these will be discussed in more detail below.

## Request Project Set

Prior to this step is a manual/human step that involves a team lead / sponsor communicating with the DevOps team and having their project/app/product accepted for deployment on the DevOps platform.

Currently the projects deployed on the platform are focused on "Continuous Service Improvement Lab"-afficilated projects, and a handful of others.

Once a verbal approval has been received, a request can be made should be made on the #requests channel of the Pathfinder DevOps Slack team. (Slack team URL: https://devopspathfinder.slack.com).  

Ideally, the above requests should include (or the requestor must have this information on-hand):
 
* the short team/organization name.  Commonly, this is the ministry name plus program area/branch, but may also be just the program area. (e.g. MOTI, OCIO, NR, EAO, DEVEX)
* product acronym/short name (e.g. EPIC, TFRS, IOT, etc.)
* product full name (e.g. Transporation Fuels Reporting System)
* 1 sentence product description
* the desired environments (e.g. dev, test, prod) 
* the GitHub ID and email address of the BC Gov employee who will be the owner/steward of the product. This should be someone with a hands-on technical skillset and is typically a developer or architect.
* (if it exists) the GitHub repo that contains the app's code. Note this must be within the BCGov GitHub organization.

At this point a member of the core DevOps platform team will action the request and create an appropriately configured set of projects on OpenShift as described below.  A notification email will be sent to the requestor when complete.

## Create Project Set

Option 1: Use Ansible Playbook, see [instruction](environment/playbook/README.md)

Option 2: Run shell script, see [instruction](environment/shell/README.md)

## Apply starter app/create initial BuildConfigs

If you have an existing repo with code that can be built on OpenShift, you can create the BuildConfigs at this point.  This may be explicitly via `oc create...` , or indirectly via `oc new-build...` or `oc new-app` 

## Populate Tools project

Note these instructions presume that there is no existing Jenkins instance withing the target `-tools` projects.  It there is, there could be name clashes that will need to be resolved. 

This step will result in a Jenkins instance being created populated with: 

* a simple, "skeleton" pipeline (captured in a Jeninsfile) that can subsequently be replaced by a team with a more tailored pipeline, 

---OR---

* a team's existing pipeline (also as a Jenkinsfile), if it exists

This is based on a special kind of BuildConfig within OpenShift called "JenkinsPipeline", which instantiates a Jenkins instance, populates it with a pipeline, and exposes the pipeline in the OpenShift console at Builds->Pipelines for execution and tracking. 

Sample command lines are provided below for either case.

### Skeleton Pipeline/Jenkinsfile
 
To instantiate a Jenkins instance populated with a "skeleton" pipeline, execute the following.  

Note that you must replace `<your-tools-project>` with the name of the `-tools` project in your project set. 

The skeleton pipeline is simply a reference for others to build upon, but it illustrates some basic features of pipelines and the integration with OpenShift.

```
oc process -f https://raw.githubusercontent.com/BCDevOps/openshift-tools/master/provisioning/pipeline/resources/pipeline-build.json -v NAME=skeleton -v SOURCE_REPOSITORY_URL=https://github.com/BCDevOps/openshift-tools -v CONTEXT_DIR=provisioning/pipeline/resources -v JENKINSFILE_PATH=Jenkinsfile-skeleton-template.txt | oc create -n <your-tools-project> -f -
```

### Existing Pipeline/Jenkinsfile

To instantiate a Jenkins instance populated with an existing pipeline, execute the following.  Note this likely presumes that you have existing BuildConfigurations, etc.  

Note that you must replace `<your-github-repo>` with the URL of your GitHub repo containing your Jenkinsfile (in its root), and replace `<your-tools-project>` with the name of the `-tools` project in your project set.
 
If your Jenkinsfile is *not* in the root of your repo, refer to the optional parameters `CONTEXT_DIR` and `JENKINSFILE_PATH` in the "Skeleton" example, above.

The skeleton pipeline is simply a reference for others to build upon, but it illustrates some basic features of pipelines and the integration with OpenShift.

```
oc process -f https://raw.githubusercontent.com/BCDevOps/openshift-tools/master/provisioning/pipeline/resources/pipeline-build.json -v NAME=skeleton -v SOURCE_REPOSITORY_URL=<your-github-repo> | oc create -n <your-tools-project> -f -
```

When you execute either of the above approaches, after few moments, a Jenkins instance and a supporting "jnlp" pod will spin up.  They can take ~5 mins or so and may even fail/restart before coming up cleanly.  This is normal/expected (due to some storage issues that we'll eventually fix). 
   
Once the process is complete, the pipeline can be started using the OpenShift console at Builds->Pipelines.

## Update/Add Pipelines

Once you have a basic pipeline executing, you can enhance the pipeline by adding other elements/capabilities. For example:

* Promotion/approvals
* Static analysis (via SonarQube)
* functional/BDD testing
* notifications (via Slack, for eg.)

Adding these capabilities is a matter of deploying the required engines (e.g. SonarQube) as well as modifiying existing (or adding) new Jenkinsfiles with the appropriate commands.  As best practices/references become available, this document will be updated.







