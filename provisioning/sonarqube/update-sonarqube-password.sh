#!/usr/bin/env bash

#generate new admin password to override silly default
admin_password=$(openssl rand -base64 8)

echo "Generated password is '$admin_password'. Enter to continue..."
read BLAH

# figure out the sonaqube route so we know where to access the API
sonarqube_url=$(oc get routes | awk '/sonarqube/{print $2}')
curl -G -X POST -v -u admin:admin --data-urlencode "login=admin" --data-urlencode "password=$admin_password" --data-urlencode "previousPassword=admin" "http://$sonarqube_url/api/users/change_password"

#guess what the sonarqube dc is.
DEFAULT_SONARQUBE_DC=$(oc get dc --no-headers | grep sonar | awk '{ print $1 }')

# allow user to override guessed value above
echo "This will update the password for your SonarQube instance."
echo -n "Enter the name of your SonarQube DC (or enter for default '$DEFAULT_SONARQUBE_DC'):"
    read SONARQUBE_DC

if [[ -z "${SONARQUBE_DC// }" ]]; then
    SONARQUBE_DC=$DEFAULT_SONARQUBE_DC
fi

#add generated password to sonarqube DC env for reference
oc env dc/$SONARQUBE_DC SONARQUBE_ADMINPW=$admin_password
