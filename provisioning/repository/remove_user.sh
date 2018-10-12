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

promptForValue ORG_NAME  "Organization name: [$ORG_NAME] " ${ORG_NAME}
promptForValue GITHUB_USER_NAME  "GitHub username: [$GITHUB_USER_NAME]" ${GITHUB_USER_NAME}

if [[ -z $GITHUB_TOKEN ]]; then
    promptForValue GITHUB_TOKEN "GitHub token:" ${GITHUB_TOKEN}
fi

GITHUB_API="https://api.github.com/orgs/${ORG_NAME}/members/${GITHUB_USER_NAME}"

#echo ${GITHUB_API}

curl -v -X DELETE -i -H "Authorization: token ${GITHUB_TOKEN}" ${GITHUB_API}

