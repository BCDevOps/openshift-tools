#!/usr/bin/env bash

#NAMESPACE                     NAME                                  TYPE      FROM                        STATUS                    STARTED              DURATION
#ll-realm                      api-chfs-1                            Source    Git@3de8392                 Complete                  5 months ago         3m25s

#BUILD_PROJECT=$1
#
#PROJECTS=""
#
#if [[ -z "${BUILD_PROJECT// }" ]]; then
#    echo "Please specify a project."
#    exit 1
#else
#    echo "Hammering builds for $BUILD_PROJECT ..."
#
#
#fi

while read line ; do
    project=$(echo $line | awk '{print $1}')
    name=$(echo $line | awk '{print $2}')
    type=$(echo $line | awk '{print $3}')
    status=$(echo $line | awk '{print $4}')
    echo "$status"
done
