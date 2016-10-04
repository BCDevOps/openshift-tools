import requests


import fileinput

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

    extra_cols = 0
    path = route_parts[3]

    if "/" in path:
        base_url = base_url + path
        extra_cols = extra_cols+1

    ssl_opt = route_parts[extra_cols+4]
    if "=" not in ssl_opt:
        protocol="https://"

    full_url = "%s%s" % (protocol, base_url)

    succeeded = []
    failed = []

    try:
        response = requests.get(full_url)
        response_code = response.status_code
        if response_code not in [200, 403, 404] :
            print "Failed... project:%s, route: %s, url: %s, response code: %d" % (project, route_name, full_url, response_code )
            failed.append(full_url)
        else:
            succeeded.append(full_url)
    except Exception as e:
        print "Gah! project:%s, route: %s, url: %s" % (project, route_name, full_url)
        print e
