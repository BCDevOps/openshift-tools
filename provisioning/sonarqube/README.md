# SonarQube provisioning

Scripts to provide an easy means to deploy SonarQube to OpenShift.

**These scripts have been deprecated.  For up-to-date information on setting up SonarQube please visit; [SonarQube on OpenShift](https://github.com/BCDevOps/sonarqube)**

## How to deploy

In this folder, you'll find two shell scripts - `deploy-sonarqube.sh` and `update-sonarqube-password.sh`.  The first is for deploying a SonarQube instance, as well as the required PostGres database instance.

To deploy, simply run the following from a command line on a system with the `oc` tool installed, and logged into OpenShift.

```
./deploy-sonarqube.sh
```

You'll be prompted to answer a few questions, all of which have default answers, which you can accept by hitting `Enter`, or provide alternative answers of your own.

Once PostGres and SonarQube instances are running, you *must* run the second script as follows to update the default SonarQube admin password:

```
./update-sonarqube-password.sh
```

## How to login
 
As you ran `update-sonarqube-password.sh` you will have seen a generated admin password displayed on the console.  You can login using the username `admin` and this password at the path where your QonrQube instance is running.

As part of the password update script, the generated admin password is also captured as an environment variable (`SONARQUBE_ADMINPW`) in the `sonarqube` DeploymentConfig (although it is not used directly by the app), meaning you can display it by:
  
 ```
 oc env dc sonarqube --list | grep SONARQUBE_ADMINPW
 ```
 

