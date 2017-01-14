#!/usr/bin/python

import sys, re, subprocess

running_builds = {}

while 1:
        line = sys.stdin.readline()
        if line == '':
                break
        try:
            line = line.rstrip('\n')
            fields = re.split(r'\s{2,}', line)

            build = { 'name' : fields[0], 'status': fields[3] }

            if build['status'] == 'Running':
                running_builds[build['name']] = build
                print("Build '{0}' is Running.".format( build['name']))
            else:
                print("Build '{0}' is {1}.".format( build['name'], build['status']))

                if (build['status'] == 'Complete') and (running_builds.has_key(build['name'])):
                    print("Build '{0}' has now Completed.".format( build['name']))
                    build_config = subprocess.check_output("oc describe build {0} | awk '/Build Config/{{print $3}}'".format(build['name']), shell=True).rstrip('\n')
                    print("Build Config is {0}".format(build_config))
                    subprocess.call("oc start-build {0}".format(build_config), shell=True)
        except Exception as e:
                print e
