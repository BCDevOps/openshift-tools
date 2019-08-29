#!/usr/bin/env bash

function concatenate_projects { local IFS="$1"; shift; echo "$*"; }

ENVIRONMENTS=()
PROJECTS=()

while getopts ":e:" env_name ;  do
  echo "Will provision environment $OPTARG"
  ENVIRONMENTS+=(${OPTARG})
done

echo -n "Enter the name of the team: "
read TEAM
echo -n "Enter the short name of the product: "
read PRODUCT
echo -n "Enter the display name of the product: "
read PRODUCT_DISPLAY
echo -n "Enter the description of the product: "
read PRODUCT_DESCRIPTION
echo -n "Enter the category of the product: "
read CATEGORY
echo -n "Enter the username for the team member who will be the admin for the new project (or enter to skip):"
read PROJECT_ADMIN_USER
echo -n "Enter the expiry date for the project set (ddmmyyyy format), if applicable (or enter to skip):"
read PROJECT_EXPIRY_DATE

if [[ "${#ENVIRONMENTS[@]}" -le "0" ]]; then
    echo -n "Enter the name of the environment: "
    read ENVIRONMENT_NAME
    ENVIRONMENTS+=(${ENVIRONMENT_NAME})
fi

GENERATED_PROJECT_NAME_PREFIX=$(LC_CTYPE=C tr -cd '[:alnum:]'  < /dev/urandom | fold -w6 | head -n1 | tr '[:upper:]' '[:lower:]')


for ENVIRONMENT in ${ENVIRONMENTS[@]}
do
  echo "Creating environment '${ENVIRONMENT}'"
      #generate default project name, ensuring lowercase
    DEFAULT_OS_PROJECT_NAME=$GENERATED_PROJECT_NAME_PREFIX-$ENVIRONMENT

    echo -n "Enter the name for the project (or enter to use a '$DEFAULT_OS_PROJECT_NAME'):"
    read OS_PROJECT_NAME

    if [[ -z "${OS_PROJECT_NAME// }" ]]; then
        OS_PROJECT_NAME=$DEFAULT_OS_PROJECT_NAME
    fi

    echo "Creating new Project called $OS_PROJECT_NAME..."

    oc new-project $OS_PROJECT_NAME --display-name="$PRODUCT_DISPLAY ($ENVIRONMENT)" --description="$PRODUCT_DESCRIPTION ($ENVIRONMENT)" --as=system:serviceaccount:openshift:bcdevops-admin

    PROJECTS+=(${OS_PROJECT_NAME})

    if [[ -z "${PROJECT_ADMIN_USER// }" ]]; then
        echo "Skipping admin user assignment."
    else
        oc policy add-role-to-user admin $PROJECT_ADMIN_USER -n $OS_PROJECT_NAME --as=system:serviceaccount:openshift:bcdevops-admin
    fi

    echo "Labelling project with basic metadata..."
    /bin/bash project_label.sh $OS_PROJECT_NAME category=$CATEGORY team=$TEAM product=$PRODUCT environment=$ENVIRONMENT project_type=user

    if [[ -n "${PROJECT_EXPIRY_DATE// }" ]]; then
        echo "Applying expiry date project..."
        /bin/bash project_label.sh $OS_PROJECT_NAME expiry=$PROJECT_EXPIRY_DATE
    fi


   # if tools project set cpu limit to 12
   if [ $ENVIRONMENT == "tools" ] 
   then
     echo "Setting $OS_PROJECT_NAME ($ENVIRONMENT) cpu limit to 12"
     oc -n $OS_PROJECT_NAME patch resourcequotas/compute-resources -p '{"spec":{"hard":{"limits.cpu": 12}}}' --as=system:serviceaccount:openshift:bcdevops-admin
   fi

done

CONCATENATED_PROJECTS=$(concatenate_projects , ${PROJECTS[@]})

echo "All projects: '${CONCATENATED_PROJECTS}'"

export CONCATENATED_PROJECTS=$CONCATENATED_PROJECTS PROJECT_ADMIN_USER=$PROJECT_ADMIN_USER

envsubst < onboarding_message.txt
