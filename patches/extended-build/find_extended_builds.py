#!/usr/bin/python

import requests
import subprocess
import functools
import itertools
import os
import yaml
from jinja2 import Template, PackageLoader, Environment

def get_authentication_token():
    result = subprocess.run(['oc', 'whoami', '-t'], stdout=subprocess.PIPE)
    return {'Authorization': "Bearer {0}".format(result.stdout.rstrip().decode('utf-8'))}


def get_namespace_resource(resource_path, project_name, params={}):

    base_api_url = get_api_base_url(resource_path)

    resource_response = requests.get('{1}/namespaces/{0}/{2}'.format(project_name, base_api_url, resource_path), headers=get_authentication_token(), params=params)
    resource_list = resource_response.json()['items']

    return resource_list


def print_resource_list(resources, resource_label ):
    for resource in resources:
        resource_name = resource['metadata']['name']
        print("{1}: {0}".format(resource_name, resource_label))

def get_api_base_url(resource_path):
    if resource_path in ['deploymentconfigs', 'buildconfigs', 'projects']:
        api_element = 'oapi'
    else:
        api_element = 'api'
    base_api_url = "https://console.pathfinder.gov.bc.ca:8443/{0}/v1".format(api_element)
    return base_api_url

def by_key(key, default, item ):
    print("Key: {0}, Default: {1}, Item: {2}".format(key, default, item))
    if key in item:
        return item[key]

def by_team(project):
    if 'labels' in project['metadata'] and 'team' in project['metadata']['labels']:
        return project['metadata']['labels']['team']
    else:
        return 'no team'

def display_project(project):

    project_name = project['metadata']['name']

    print("Project: {0}".format(project_name))
    print("Project JSON: {0}".format(project))
    annotations = project['metadata']['annotations']

    for key in annotations:
        print("Annotation: {0}: {1}".format(key, annotations[key]))

    if 'labels' in project['metadata']:
        labels = project['metadata']['labels']

        for key in labels:
            print("Label: {0}: {1}".format(key, labels[key]))

    get_namespace_resource("deploymentconfigs", "Deployment Configuration", project_name)
    get_namespace_resource("buildconfigs", "Build Configuration", project_name)


def normalize_storage(storage_string):
    if 'G' in storage_string:
        return int(''.join([i for i in storage_string if i.isdigit()]))
    elif 'M' in storage_string:
        return int(''.join([i for i in storage_string if i.isdigit()])) / 1000

def normalize_cpu(cpu_string):
    if 'm' in cpu_string:
        return int(''.join([i for i in cpu_string if i.isdigit()])) / 1000
    else:
        return int(cpu_string)

def get_projects():

    project_response = requests.get("{0}/projects".format(get_api_base_url('projects')), headers=get_authentication_token())
    projects = project_response.json()['items']

    for project in projects:
        pass
        # display_project(project)

    projects = sorted(projects, key=by_team)

    projects_by_team = itertools.groupby(projects, by_team)

    for team,projects in projects_by_team:
        # print("Team: {0}".format(team))
        sorted_projects = sorted(projects,key=lambda p: p['metadata']['name'] )
        for project in sorted_projects:
            project_name=project['metadata']['name']
            # print("Project: {0}".format(project['metadata']['name']))

            # summarize_pods(project_name)

            # summarize_pvcs(project_name)

            summarize_builds(project_name)


def summarize_builds(project_name):
    build_configs = get_namespace_resource("buildconfigs", project_name)

    if build_configs:
        for build_config in build_configs:

            build_config_name = build_config['metadata']['name']
            build_strategy = build_config['spec']['strategy']
            if build_strategy.get('sourceStrategy', {}).get('runtimeImage'):

                project_dir = "output/{0}".format(project_name)
                if not os.path.exists(project_dir):
                    os.makedirs(project_dir)

                build_config_dir = "{0}/{1}".format(project_dir, build_config_name)
                if not os.path.exists(build_config_dir):
                    os.makedirs(build_config_dir)

                build_config_dir_abspath = os.path.abspath(build_config_dir)

                print("===============================================")
                print("{1}/{0}".format(build_config_name, project_name))
                print("===============================================")

                spec = build_config.get('spec')
                # pretty_spec = yaml.dump(spec)
                # print(pretty_spec)

                git_source = spec['source']['git']['uri']
                git_branch = spec['source']['git'].get('ref')
                context_dir = spec['source'].get('contextDir')
                runtime_image = spec['strategy']['sourceStrategy']['runtimeImage']['name']
                runtime_image_namespace = spec['strategy']['sourceStrategy']['runtimeImage'].get('namespace')
                output_image = spec['output']['to']['name']
                print("repo: {0}".format(git_source))
                if git_branch:
                    print("branch: {0}".format(git_branch))
                if context_dir:
                    print("contextDir: {0}".format(context_dir))
                print("runtimeImage: {0}".format(runtime_image))
                if runtime_image_namespace:
                    print("runtimeImage namespace: {0}".format(runtime_image_namespace))
                print("outputImage: {0}".format(output_image))

                env = Environment(loader=PackageLoader('find_extended_builds', 'templates'))

                new_app_template = env.get_template('new_app.tmpl')
                app_build_name = "{0}-angular-app".format(build_config_name )
                new_app_text = new_app_template.render(project_name=project_name,app_build_name=app_build_name, git_source=git_source,
                                                 git_branch=git_branch, context_dir=context_dir)

                new_app_script_name = "new_app.sh"
                new_app_output_file_full_path = "{0}/{1}".format(build_config_dir_abspath, new_app_script_name)
                fh = open(new_app_output_file_full_path, "w")
                fh.writelines(new_app_text)
                fh.close()
                os.chmod(new_app_output_file_full_path, 0o777)

                # execute the script we just created
                subprocess.run([new_app_output_file_full_path], stdout=subprocess.PIPE, cwd=build_config_dir_abspath)

                template = env.get_template('patch.tmpl')
                app_build_output_imagestream = "{0}:latest".format(app_build_name)
                patch_text = template.render(project_name=project_name, build_config_name=build_config_name, app_build_output_imagestream=app_build_output_imagestream, runtime_image=runtime_image, runtime_image_namespace=runtime_image_namespace, output_image=output_image)

                patch_script_file_name = "patch.sh"
                patch_output_file_full_path = "{0}/{1}".format(build_config_dir_abspath, patch_script_file_name)
                fh = open(patch_output_file_full_path, "w")
                fh.writelines(patch_text)
                fh.close()
                os.chmod(patch_output_file_full_path, 0o777)

                # execute the script we just created
                subprocess.run([patch_output_file_full_path], stdout=subprocess.PIPE, cwd=build_config_dir_abspath)


def summarize_pvcs(project_name):
    pvcs = get_namespace_resource("persistentvolumeclaims", project_name)
    if pvcs:
        storage = functools.reduce(lambda total_storage, usage: total_storage + usage,
                                   map(lambda pvc: normalize_storage(pvc['spec']['resources']['requests']['storage']),
                                       pvcs))

        print("Number of PVCs: {0}".format(len(list(pvcs))))
        print("Total storage usage: {0}".format(storage))


def summarize_pods(project_name):
    pods = get_namespace_resource("pods", project_name)
    pods = itertools.filterfalse(lambda pod: pod['status']['phase'] != 'Running', pods)
    pods = list(pods)
    print("Number of pods: {0}".format(len(pods)))
    if pods:
        # for pod in pods:
        #     print("Pod:{0}".format(pod))
        cpu = functools.reduce(lambda resource, limit: resource + limit, map(
            lambda pod: normalize_cpu(pod['spec']['containers'][0]['resources']['limits']['cpu']), pods))
        print("Total CPU usage: {0}".format(cpu))

        memory = functools.reduce(lambda resource, limit: resource + limit, map(
            lambda pod: normalize_storage(pod['spec']['containers'][0]['resources']['limits']['memory']), pods))
        print("Total Memory usage: {0}".format(memory))


get_projects()

