#!/usr/bin/env bash

# default is to deploy into current project
DEFAULT_PROJECT=$(oc project --short)

#allow user to specify another project
echo "This will instantiate a SonarQube instance."
echo -n "Enter the name of the project where SonarQube should be instantiated (or enter for current project '$DEFAULT_PROJECT'):"
    read OS_PROJECT_NAME

if [[ -z "${OS_PROJECT_NAME// }" ]]; then
    OS_PROJECT_NAME=$DEFAULT_PROJECT
fi

DEFAULT_SONAR_ROUTE="$OS_PROJECT_NAME-sonarqube.pathfinder.gov.bc.ca"

echo -n "Enter the URL for the SonarQube  route (or enter for current project '$DEFAULT_SONAR_ROUTE'):"
    read SONAR_ROUTE

if [[ -z "${SONAR_ROUTE// }" ]]; then
    SONAR_ROUTE=$DEFAULT_SONAR_ROUTE
fi

#deploy a postgres instance for sonar to use
oc new-app postgresql-persistent -p POSTGRESQL_USER=sonarqube,POSTGRESQL_DATABASE=sonarqube,DATABASE_SERVICE_NAME=postgresql-sonarqube -n $OS_PROJECT_NAME -l "app=sonarqube"

#extract the password from the postgres instance we just created
postgres_password=$(oc env dc postgresql-sonarqube --list | awk  -F  "=" '/POSTGRESQL_PASSWORD/{print $2}')

#deploy sonar in the selected project using the template in the current directory, passing jdbc passsword, etc. as params
oc process -f sonarqube-deploy.json -v SONARQUBE_ROUTE_URL=$SONAR_ROUTE,SONARQUBE_JDBC_USERNAME=sonarqube,SONARQUBE_JDBC_PASSWORD=$postgres_password | oc create -n $OS_PROJECT_NAME -f -


echo "*****IMPORTANT**** Once SonarQube has successfully deployed and initialized (takes a couple minutes), you must run ./update-sonarqube-password.sh to ensure the default admin password is regenerated."
