import requests

import re
import fileinput
import sys
import concurrent.futures

from datetime import datetime

routes = []
# for stats if we ever wanted to print at the end of a run.
succeeded = []
failed = []

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

    try:
        response = requests.get(full_url)
        response_code = response.status_code
        if response_code not in [200, 403, 404] :
            print("time='{0}', error=Failed with bad status, project={1}, route_name={2}, route={3}, response_code={4} ".format(datetime.now(), project, route_name, full_url, response_code))
            failed.append(full_url)
        else:
            succeeded.append(full_url)
    except Exception as e:
        print("time='{0}',error=Failed with Exception, project={1}, route_name={2}, route={3}, exception='{4}''".format(datetime.now(), project, route_name, full_url, e))


for route in fileinput.input():
    routes.append(route)

executor = concurrent.futures.ThreadPoolExecutor(max_workers=10)

for route in routes:
    executor.submit(check_route, route)

if len(failed) > 0:
    sys.exit(len(failed))
