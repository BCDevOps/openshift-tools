import requests

urls = ['https://bcdevexchange.org/','http://lets-chat-letschat.pathfinder.gov.bc.ca/','https://esm-jenkins-esm.pathfinder.gov.bc.ca/','https://embed-bcdevexchange-prod.pathfinder.gov.bc.ca/','https://embed-bcdevexchange-prod.pathfinder.gov.bc.ca/api/issues','https://dbcfeeds-t.pathfinder.gov.bc.ca/feeds']

for attempt in range(1,100):
    print "Attempt %d" % attempt
    for url in urls:
        response = requests.get(url)
        print "."
        if response.status_code not in [200, 403] :
            print "%s failed...." % url
            print response.raw
