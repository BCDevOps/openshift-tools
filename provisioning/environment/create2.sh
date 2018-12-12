#!/usr/bin/env bash
set -Eeu
#set -o pipefail

#TEMPLATE_NAME="$1"
ADMIN_USER="system:serviceaccount:openshift:bcdevops-admin"
TEMP_NAMESPACE="bcgov-tools"

echo "" > input.env
for i in "$@"
do
case $i in
    --template=*)
    TEMPLATE_NAME="${i#*=}"
    shift # past argument=value
    ;;
    --prefix=*)
    PREFIX="${i#*=}"
    echo "NAME=${PREFIX}" >> input.env
    shift # past argument=value
    ;;
    --category=*)
    CATEGORY="${i#*=}"
    echo "CATEGORY=${CATEGORY}" >> input.env
    shift # past argument=value
    ;;
    --product=*)
    PRODUCT="${i#*=}"
    echo "PRODUCT=${PRODUCT}" >> input.env
    shift # past argument=value
    ;;
    --description=*)
    DESCRIPTION="${i#*=}"
    echo "DESCRIPTION=${DESCRIPTION}" >> input.env
    shift # past argument=value
    ;;
    --admin=*)
    ADMIN="${i#*=}"
    echo "ADMIN=${ADMIN}" >> input.env
    shift # past argument=value
    ;;
    --team=*)
    TEAM="${i#*=}"
    echo "TEAM=${TEAM}" >> input.env
    shift # past argument=value
    ;;
    *)
    # unknown option
    ;;
esac
done

if [ -z ${PREFIX+x} ]; then
    echo 'Generating prefix ...'
    PREFIX=$(LC_CTYPE=C tr -cd '[:alnum:]'  < /dev/urandom | fold -w6 | head -n1 | tr '[:upper:]' '[:lower:]')
    echo "Generated Prefix -> ${PREFIX}"
    echo "NAME=${PREFIX}" >> input.env
else
    if [[ $PREFIX =~ ([[:space:]]+) ]]; then
        echo "Whitespace not allowed in 'prefix'"
        is_valid=0
    fi
fi

is_valid=1

if [ -z ${CATEGORY+x} ]; then
    echo "Missing '--category=' argument"
    is_valid=0
else
    case $CATEGORY in
        pathfinder)
        ;;
        sandbox)
        ;;
        spark)
        ;;
        sandbox)
        ;;
        venture)
        ;;
        poc)
        ;;
        *)
            echo "Unknonw category ('${CATEGORY}')"
            is_valid=0
        ;;
    esac
fi

if [ -z ${PRODUCT+x} ]; then
    echo "Missing '--product=' argument"
    is_valid=0
else
    if [[ $PRODUCT =~ ([[:space:]]+) ]]; then
        echo "Whitespace not allowed in 'product'"
        is_valid=0
    fi
fi

if [ -z ${DESCRIPTION+x} ]; then
    echo "Missing '--description=' argument"
    is_valid=0
fi

if [ -z ${ADMIN+x} ]; then
    echo "Missing '--admin=' argument"
    is_valid=0
else
    if [[ $ADMIN =~ ([[:space:]]+) ]]; then
        echo "Whitespace not allowed in 'admin'"
        is_valid=0
    fi
fi

if [ -z ${TEAM+x} ]; then
    echo "Missing '--team=' argument"
    is_valid=0
else
    if [[ $TEAM =~ ([[:space:]]+) ]]; then
        echo "Whitespace not allowed in 'team'"
        is_valid=0
    fi
fi

if [ -z ${TEMPLATE_NAME+x} ]; then
    echo "Missing '--template=' argument"
    is_valid=0
else
    if [[ $TEMPLATE_NAME =~ ([[:space:]]+) ]]; then
        echo "Whitespace not allowed in 'template'"
        is_valid=0
    fi
fi

if [ "$is_valid" -eq "0" ]; then
    echo "Invalid arguments"
    exit 1
fi

if [ ! -f "templates/openshift-${TEMPLATE_NAME}.yaml" ]; then
    echo "ERROR: Teplate not found (templates/openshift-${TEMPLATE_NAME}.yaml)"
    exit 1
fi

rm -rf temp*.json
rm -rf temp*.lst


read -p "Press enter to continue"


#Process Template

oc "--as=$ADMIN_USER" -n "${TEMP_NAMESPACE}"  process -f "templates/openshift-${TEMPLATE_NAME}.yaml" --param-file=input.env -o json > temp.json

#Generate list of Project/Namespace
jq -r '[.items[] | select(.metadata.namespace != null) | .metadata.namespace] | unique | .[]' temp.json > temp.namespaces.lst

#Create Namespace/Project
while read namespace; do ( oc "--as=$ADMIN_USER" get "namespace/$namespace" >/dev/null 2>&1 || oc "--as=$ADMIN_USER" new-project "$namespace" ); done < "temp.namespaces.lst"

#Update Project Metadata labels/annotations
while read namespace; do ( jq -r "{\"kind\":\"List\", \"items\":[.items[] | select(.kind == \"Project\" and .metadata.name == \"$namespace\") | .kind = \"Namespace\" | .apiVersion = \"v1\"]}" temp.json | oc "--as=$ADMIN_USER" -n "$namespace" apply -f - ); done < "temp.namespaces.lst"

oc  "--as=$ADMIN_USER" "--namespace=$namespace" get ResourceQuota -l 'custom' --ignore-not-found=true > "custom.resources.lst"

#Cleanup default stuff
while read namespace; do ( oc  "--as=$ADMIN_USER" "--namespace=$namespace" delete ResourceQuota -l '!custom' --ignore-not-found=true  ); done < "temp.namespaces.lst"

#Apply Quota and any other namespace-specific object
while read namespace; do ( jq -r "{\"kind\":\"List\", \"items\":[.items[] | select(.metadata.namespace == \"$namespace\")]}" temp.json | oc "--as=$ADMIN_USER" -n "$namespace" apply -f - ); done < "temp.namespaces.lst"



#ocadm -n bcgov policy add-role-to-group 'shared-resource-viewer' system:authenticated
