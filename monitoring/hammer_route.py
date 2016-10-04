import requests
import fileinput
import time


routes = []
succeeded = []
failed = []

for route in fileinput.input():
    routes.append(route.rstrip())


while True:
    time.sleep(1)
    for full_url in routes:
        try:
            print "Trying... , url: '%s'" % full_url
            response = requests.get(full_url, headers = {"x-apicache-bypass": "true" } )
            response_code = response.status_code
            if response_code not in [200, 403, 404] :
                print "Failed... , url: %s, response code: %d" % (full_url, response_code )
                failed.append(full_url)
            else:
                print "Succeeded... , url: %s, response code: %d" % (full_url, response_code )
                succeeded.append(full_url)
        except Exception as e:
            print "Gah! url: %s" % (full_url)
            print e
