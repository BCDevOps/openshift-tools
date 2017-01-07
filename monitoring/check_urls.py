import requests

import re
import fileinput
import sys

routes = []

for route in fileinput.input():
    routes.append(route)

for route in routes:
    route_parts = route.split()
    project = route_parts[0]
    route_name = route_parts[1]

    base_url = route_parts[2]

    if "bcgov" in base_url:
        continue

    protocol = "http://"

    # pat = re.search('edge|Redirect')
    if re.search('edge|Redirect', route):
        protocol = "https://"

    extra_cols = 0
    path = route_parts[3]

    if "/" in path:
        base_url = base_url + path
        extra_cols = extra_cols+1

    full_url = "%s%s" % (protocol, base_url)

    succeeded = []
    failed = []

    try:
        response = requests.get(full_url)
        response_code = response.status_code
        if response_code not in [200, 403, 404] :
            print "\nFailed... project:%s, route: %s, url: %s, response code: %d" % (project, route_name, full_url, response_code )
            sys.stdout.flush()
            failed.append(full_url)
        else:
            sys.stdout.write('.')
            sys.stdout.flush()
            succeeded.append(full_url)
    except Exception as e:
        print "\nFailed (with Exception) ... project:%s, route: %s, url: %s, exception: %s" % (project, route_name, full_url, e )

        # print "\nGah! project:%s, route: %s, url: %s" % (project, route_name, full_url)
        # print e

    # for successful_route in  succeeded:
    #     print "Succeed: %s" % (successful_route)
