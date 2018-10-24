#!/usr/bin/env bash

#this is an example of how to create a "status" to be used as part of a pull-request workflow.

# provide a variable to write to as $1, prompt text as $2 and a default value for $3
function promptForValue {
    local __resultvar=$1
    local __default=$3

    echo -n "$2"
    read VALUE

    if [[ -z "${VALUE// }" ]]; then
        eval $__resultvar="'$__default'"
    else
        eval $__resultvar="'$VALUE'"
    fi
}

promptForValue ORG_NAME  "Organization name [$ORG_NAME]: " ${ORG_NAME}
promptForValue REPO_NAME  "Repo name [$REPO_NAME]: " ${REPO_NAME}
promptForValue SHA  "Commit SHA [$SHA]: " ${SHA}

if [[ -z $GITHUB_TOKEN ]]; then
    promptForValue GITHUB_TOKEN "GitHub token:" ${GITHUB_TOKEN}
fi

read -r -d '' payload << EOM
{
  "state": "success",
  "target_url": "https://developer.gov.bc.ca/members/status",
  "description": "The check succeeded!",
  "context": "profile_checker"
}
EOM

GITHUB_API="https://api.github.com/repos/${ORG_NAME}/${REPO_NAME}/statuses/${SHA}"

echo $GITHUB_API

curl -i -H "Authorization: token ${GITHUB_TOKEN}" ${GITHUB_API} -d "$payload"
