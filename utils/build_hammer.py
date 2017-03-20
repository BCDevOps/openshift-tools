#!/usr/bin/python

import sys, re, subprocess

running_builds = {}

build_count=0
target_build_count=int(sys.argv[1])

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

                if (build['status'] == 'Complete') and (build['name'] in running_builds):
                    print("Build '{0}' has now Completed.".format( build['name']))
                    build_config = subprocess.check_output("oc describe build {0} | awk '/Build Config/{{print $3}}'".format(build['name']), shell=True).rstrip('\n')
                    print("Build Config is {0}".format(build_config))

                    build_count = build_count+1

                    if build_count < target_build_count:
                        print("Build count is '{0}', target is '{1}'.".format(build_count, target_build_count))
                        subprocess.call("oc start-build {0}".format(build_config), shell=True)
                    else:
                        sys.exit(0)
        except Exception as e:
                print(e)
