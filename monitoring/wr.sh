#!/bin/bash

date

for n in 124 125 126 127 128 129 130 131 132 133 134 135 199
do
        CLOAD=$(ssh -q ociopf-d-$n.dmz "w | grep load | sed -e 's/users,  /users, /' -e 's/load average/Load/'")
        CVOLS=$(ssh -q ociopf-d-$n.dmz "df -h | grep openshift.local.volumes | wc -l")
        oc describe node ociopf-d-$n.dmz | egrep -A 4 'Name:|Allocated resources:|Kubelet Version:' | egrep 'Name:|%|Non-terminated Pods' | sed -e 's/Non-terminated Pods://g' -e 's/Name://g' | perl -p -i -e 's/dmz\n/dmz /g' | perl -p -i -e 's/in total\)\n/ /g' | tr -d '()' | awk '{print "Node:", $1, " Pods:", $2, " CPU:", $4, " Memory:", $8}' | perl -p -i -e 's/\n//'
        echo "  Volumes: $CVOLS  Uptime:$CLOAD"
done

