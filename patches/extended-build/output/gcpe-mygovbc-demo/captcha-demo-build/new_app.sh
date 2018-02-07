#!/usr/bin/env bash

oc process -f https://raw.githubusercontent.com/bcgov/angular-scaffold/master/openshift/templates/angular-app/angular-app.json -o json -p NAME=captcha-demo-build-angular-app -p GIT_REPO_URL=https://github.com/bcgov/angular-scaffold-captcha   > captcha-demo-build-angular-app-bc.json