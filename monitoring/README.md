# OpenShift Monitoring Scripts

This folder contains a set of scripts related to monitoring / checking of OpenShift or OpenShift-deployed resources.

## check_urls

This script dynamically pulls in the set of routes across all projects in OpenShift and checks them.

Requirements:

* python 3+
* requests lib (eg. ```pip install requests```)

To run:

```
./check_urls.sh
```

There will be "false negatives" due to orphaned routes or broken apps, but the purpose of this script is mainly to check whether the router is experiencing problems, not to test specific apps.
