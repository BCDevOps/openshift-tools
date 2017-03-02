#!/usr/bin/python

import requests

headers = {'Authorization': 'Bearer <TOKEN>'}
response = requests.get('https://console.pathfinder.gov.bc.ca:8443/oapi/v1/projects', headers=headers)

projects = response.json()['items']

for project in projects:
    project_name = project['metadata']['name']
    response = requests.get('https://console.pathfinder.gov.bc.ca:8443/api/v1/namespaces/{0}/limitranges'.format(project_name), headers=headers)
    # print(response.json())
    limit_range = response.json()['items']
    if limit_range:
        print(".")
        # print(limit_range)
        # print("Project '{0}' limit range: '{1}'".format(project_name,limit_range[0]['spec']['limits'][0]['defaultRequest']['cpu']))
    else:
        print("Project '{0}' has no limit range.".format(project_name))
