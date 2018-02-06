#!/usr/bin/env bash

oc process -f https://raw.githubusercontent.com/bcgov/angular-scaffold/master/openshift/templates/angular-app/angular-app.json -o json -p NAME=angular-app -p GIT_REPO_URL=https://github.com/bcgov/eao-public   > angular-app-bc.json