#!/usr/bin/env bash

oc process -f https://raw.githubusercontent.com/bcgov/angular-scaffold/master/openshift/templates/angular-app/angular-app.json -o json -p NAME=msp-1.3-prototype-build-angular-app -p GIT_REPO_URL=https://github.com/bcgov/MyGovBC-MSP.git -p GIT_REF=1.3-prototype   > msp-1.3-prototype-build-angular-app-bc.json