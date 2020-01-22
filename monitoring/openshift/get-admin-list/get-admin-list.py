import requests
import os
import json


# get/format the token and endpoint from oc - make sure you're logged in first.
oc_token = os.popen('oc whoami -t').read()
oc_endpoint = os.popen('oc config current-context | cut -d/ -f2 | tr - .').read()
oc_token = oc_token.strip()
oc_endpoint = oc_endpoint.strip()

# set headers for curl request
headers = {
    'Authorization': 'Bearer ' + oc_token,
    'Accept': 'application/json',
}

# issue request and convert json to python dict
response = requests.get('https://' + oc_endpoint + '/apis/authorization.openshift.io/v1/namespaces/9wbi3f-tools/rolebindings', headers=headers, verify=False)
rolebindings_dict = response.json()
print(rolebindings_dict)

