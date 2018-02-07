#!/usr/bin/env bash

oc process -f https://raw.githubusercontent.com/bcgov/angular-scaffold/master/openshift/templates/angular-app/angular-app.json -o json -p NAME=msp-splash-build-angular-app -p GIT_REPO_URL=https://github.com/bcgov/MyGovBC-MSP.git -p GIT_REF=msp-splash   > msp-splash-build-angular-app-bc.json