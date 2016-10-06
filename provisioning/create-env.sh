#!/usr/bin/env bash

ENVIRONMENTS=()

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
echo -n "Enter the path to the environment creation template (or enter to skip): "
read CREATE_SCRIPT
echo -n "Enter the username name for the user who will be the admin for the new project (or enter to skip):"
read PROJECT_ADMIN_USER

if [[ "${#ENVIRONMENTS[@]}" -le "0" ]]; then
    echo -n "Enter the name of the environment: "
    read ENVIRONMENT_NAME
    ENVIRONMENTS+=(${ENVIRONMENT_NAME})
fi

for ENVIRONMENT in ${ENVIRONMENTS[@]}
do
  echo "${ENVIRONMENT}"
      #generate default project name, ensuring lowercase
    DEFAULT_OS_PROJECT_NAME=$(echo $TEAM-$PRODUCT-$ENVIRONMENT  | tr '[:upper:]' '[:lower:]')

    echo -n "Enter the name for the project (or enter to use a '$DEFAULT_OS_PROJECT_NAME'):"
    read OS_PROJECT_NAME

    if [[ -z "${OS_PROJECT_NAME// }" ]]; then
        OS_PROJECT_NAME=$DEFAULT_OS_PROJECT_NAME
    fi

    echo "Creating new Project called $OS_PROJECT_NAME..."

    oc new-project $OS_PROJECT_NAME --display-name="$PRODUCT_DISPLAY ($ENVIRONMENT)" --description="$PRODUCT_DESCRIPTION ($ENVIRONMENT)"


    if [[ -z "${CREATE_SCRIPT// }" ]]; then
        echo "Skipping project resource creation."
    else
        if [ -e $CREATE_SCRIPT ]; then
            echo "Creating project resources from file $CREATE_SCRIPT..."
            oc create -f $CREATE_SCRIPT -n $OS_PROJECT_NAME
        fi
    fi

    if [[ -z "${PROJECT_ADMIN_USER// }" ]]; then
        echo "Skipping project resource creation."
    else
        oc policy add-role-to-user admin $PROJECT_ADMIN_USER -n $OS_PROJECT_NAME
    fi

    echo "Labelling project..."

    /bin/bash project_label.sh $OS_PROJECT_NAME category=$CATEGORY team=$TEAM product=$PRODUCT environment=$ENVIRONMENT
done


