#!/usr/bin/env bash

# example : ./populate_repo.sh -s bcdevops -r opendev-template -t bcgov -d splunk-forwarder
# above would copy contents from https://github.com/bcdevops/opendev-template to existing (probably empty repo) https://github.com/bcgov/splunk-forwarder


bare_clone() {
    local SOURCE_ORG_OR_USER="$1";
    local SOURCE_REPO="$2";

    SOURCE_REPO_URL="https://github.com/${SOURCE_ORG_OR_USER}/${SOURCE_REPO}.git"

    echo "Source repo URL is ${SOURCE_REPO_URL}" >&2

    git clone --bare ${SOURCE_REPO_URL}
}

mirror_push() {

    local TARGET_ORG_OR_USER="$1";
    local TARGET_REPO="$2";

    PUSH_TARGET_REPO="git@github.com:${TARGET_ORG_OR_USER}/${TARGET_REPO}.git"

    echo "Push repo URL is ${PUSH_TARGET_REPO}" >&2

    git push --mirror $PUSH_TARGET_REPO
}

while getopts ":srtd:h" opt; do
  case $opt in
    s)
      SOURCE_USER_OR_ORG=$OPTARG
      echo "source user is $SOURCE_USER_OR_ORG" >&2
      ;;
    r)
      SOURCE_REPO=$OPTARG
      echo "source repo is $SOURCE_REPO" >&2
      ;;
    t)
      TARGET_ORG_OR_USER=$OPTARG
      echo "target org or user is $TARGET_ORG_OR_USER" >&2
      ;;
    d)
      TARGET_REPO=$OPTARG
      echo "target repo is $TARGET_REPO" >&2
      ;;
    h)
      echo "usage: './populate_repo.sh -s <source org|user> -r <source repo> -t <target org|user> -d <target repo (must exist)>'" >&2
      exit 0
      ;;
    :)
      echo "missing argument(s)" >&2
      exit 1
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

if [ ! -d "$SOURCE_REPO.git" ]; then
    bare_clone $SOURCE_USER_OR_ORG $SOURCE_REPO
fi

cd $SOURCE_REPO.git

mirror_push $TARGET_ORG_OR_USER $TARGET_REPO


