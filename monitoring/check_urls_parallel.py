import requests

import re
import fileinput
import sys
import concurrent.futures

routes = []

def check_route(route):
    route_parts = route.split()
    project = route_parts[0]
    route_name = route_parts[1]

    base_url = route_parts[2]

    if "bcgov" in base_url:
        return

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

    # for stats if we ever wanted to print at the end of a run.
    succeeded = []
    failed = []

    try:
        response = requests.get(full_url)
        response_code = response.status_code
        if response_code not in [200, 403, 404] :
            print("error=Failed with bad status, project={0}, route_name={1}, route={2}, response_code={3} ".format(project, route_name, full_url, response_code))
            failed.append(full_url)
        else:
            succeeded.append(full_url)
    except Exception as e:
        print("error=Failed with Exception, project={0}, route_name={1}, route={2}, exception={3}".format(project, route_name, full_url, e))


for route in fileinput.input():
    routes.append(route)

executor = concurrent.futures.ThreadPoolExecutor(max_workers=10)

for route in routes:
    executor.submit(check_route, route)
