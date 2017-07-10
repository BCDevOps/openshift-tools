#!/usr/bin/env bash

#
# Script to easily set up webhooks for existing build configurations.
#
#
#

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

promptForValue PROJECT_NAME "Project name: " $(oc project -q)

echo "Project is: $PROJECT_NAME"

promptForValue BUILD_CONFIG_NAME "BuildConfiguration name: "

echo "BuildConfig is '$BUILD_CONFIG_NAME'"

GITHUB_REPO=$(oc export bc ${BUILD_CONFIG_NAME} -o jsonpath --template={.spec.source.git.uri})
echo "REPO: ${GITHUB_REPO}"

GITHUB_API=$(echo ${GITHUB_REPO} | sed s/github.com/api.github.com\\/repos/)
GITHUB_API=${GITHUB_API::${#GITHUB_API}-4}"/hooks"

echo "GITHUB_API: ${GITHUB_API}"

WEBHOOK_URL=$(oc describe bc ${BUILD_CONFIG_NAME} -n ${PROJECT_NAME} | grep -A1 GitHub | awk '/URL/{print $2}')
echo "WEBHOOK: ${WEBHOOK_URL}"

echo "Updating webhook link ${WEBHOOK_URL} for repo ${GITHUB_REPO}"

promptForValue GITHUB_TOKEN "GitHub token: " ${GITHUB_TOKEN}

read -r -d '' payload << EOM
{
  "name": "web",
  "events": [
    "push"
  ],
  "config": {
    "url": "${WEBHOOK_URL}",
    "content_type": "json",
    "insecure_ssl": "1"
  }
}
EOM

curl -i -H "Authorization: token ${GITHUB_TOKEN}" ${GITHUB_API} -d "$payload"






