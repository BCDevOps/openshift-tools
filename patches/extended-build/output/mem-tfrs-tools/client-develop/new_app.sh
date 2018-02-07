#!/usr/bin/env bash

oc process -f https://raw.githubusercontent.com/bcgov/angular-scaffold/master/openshift/templates/angular-app/angular-app.json -o json -p NAME=client-develop-angular-app -p GIT_REPO_URL=https://github.com/bcgov/tfrs.git -p GIT_REF=develop   -p SOURCE_CONTEXT_DIR=frontend  > client-develop-angular-app-bc.json