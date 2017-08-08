#!/usr/bin/env bash

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

promptForValue ORG_NAME  "Organization name: " ${ORG_NAME}
promptForValue REPO_NAME  "Repo name: " ${REPO_NAME}
promptForValue REPO_DESCRIPTION  "Repo description: " ${REPO_DESCRIPTION}
promptForValue GITHUB_TOKEN "GitHub token: " ${GITHUB_TOKEN}

read -r -d '' payload << EOM
{
  "name": "${REPO_NAME}",
  "description": "${REPO_DESCRIPTION}",
  "private": false,
  "has_issues": true,
  "has_projects": true,
  "has_wiki": true
}
EOM

GITHUB_API="https://api.github.com/orgs/${ORG_NAME}/repos"

curl -i -H "Authorization: token ${GITHUB_TOKEN}" ${GITHUB_API} -d "$payload"
