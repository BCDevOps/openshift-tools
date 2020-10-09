import subprocess
import requests
import re
import json


def get_pods():
    token = subprocess.run(['oc', 'whoami', '-t'], stdout=subprocess.PIPE)
    api_url = 'https://console.pathfinder.gov.bc.ca:8443/api/v1/pods'
    headers = {
        'Authorization': "Bearer " + token.stdout.rstrip().decode('utf-8'),
        'Accept': 'application/json'
               }

    try:
        response = requests.get(api_url, headers=headers)
        response_list = response.json()['items']

        # get a complete list of all the pods that contain databases
        db_pods = {}
        all_images = []
        results = {
            'namespaces': 0,
            'postgres': 0,
            'mongo': 0,
            'mysql': 0,
            'redis': 0,
            'other': 0,
            'total': 0
        }
        for pod in response_list:
            containers_list = pod['spec']['containers']
            is_db = False
            type = 'other'

            # loop through the containers in the pod - usually only one, but just in case.
            for container in containers_list:

                # collect a unique list of all images, for later reference to make sure we're catching all the dbs.
                image_parts = container['image'].split('@sha')[0].split('/')
                image_name = image_parts[len(image_parts)-1]
                image_parts = image_name.split(':')
                image_name = image_parts[0]
                if image_name not in all_images:
                    if bool(re.search(".*sql.*|.*db.*", image_name)):
                        all_images.append(image_name)

                # if it's a postgres-type database in this container, mark it
                if bool(re.search(".*postgres.*|.*patroni.*|.*crunchy.*|.*psql.*|.*edb.*", image_name)):
                    is_db = True
                    type = 'postgres'
                # if it's a mongo-type database in this container, mark it
                elif bool(re.search(".*mongo.*", image_name)):
                    is_db = True
                    type = 'mongo'
                # if it's a mysql-type database in this container, mark it
                elif bool(re.search(".*mysql.*|.*mariadb.*", image_name)):
                    is_db = True
                    type = 'mysql'
                # if it's a redis-type database in this container, mark it
                elif bool(re.search(".*redis.*", image_name)):
                    is_db = True
                    type = 'redis'
                # if it's an other-type database in this container, mark it
                elif bool(re.search(".*sql.*|.*db.*", image_name)):
                    is_db = True
                    type = 'other'

            # it it's a database (probably) and it's actually running...
            if is_db and pod['status']['phase'] == 'Running':
                # if the namespace is already recorded, add the ss/dc name, but only if it's unique to that namespace
                if pod['metadata']['namespace'] in db_pods:
                    # if it's a statefulset...
                    if 'statefulset' in pod['metadata']['labels']:
                        if pod['metadata']['labels']['statefulset'] not in db_pods[pod['metadata']['namespace']]:
                            db_pods[pod['metadata']['namespace']].append(pod['metadata']['labels']['statefulset'])
                            results[type] += 1
                    # if it's a deploymentconfig...
                    elif 'deploymentconfig' in pod['metadata']['labels']:
                        db_pods.update({pod['metadata']['namespace']: [pod['metadata']['labels']['deploymentconfig']]})
                        results[type] += 1
                    # if it's something else... ?!?!
                    else:
                        db_pods.update({pod['metadata']['namespace']: [pod['metadata']['labels']]})
                        results[type] += 1
                # otherwise, add the new namespace to the dict.
                else:
                    # if it's a statefulset...
                    if 'statefulset' in pod['metadata']['labels']:
                        db_pods.update({pod['metadata']['namespace']: [pod['metadata']['labels']['statefulset']]})
                        results[type] += 1
                    # if it's a deploymentconfig...
                    elif 'deploymentconfig' in pod['metadata']['labels']:
                        db_pods.update({pod['metadata']['namespace']: [pod['metadata']['labels']['deploymentconfig']]})
                        results[type] += 1
                    # if it's something else... ?!?!
                    else:
                        db_pods.update({pod['metadata']['namespace']: [pod['metadata']['labels']]})
                        results[type] += 1

        results['namespaces'] = len(db_pods)
        results['total'] = results['mongo'] + results['postgres'] + results['mysql'] + results['redis'] + results['other']
        #print(json.dumps(db_pods, indent=4))
        #print(*all_images, sep="\n")
        print(results)
        #print(json.dumps(response_list[0], indent=4))

    except json.JSONDecodeError:
        print(json.JSONDecodeError)


get_pods()
