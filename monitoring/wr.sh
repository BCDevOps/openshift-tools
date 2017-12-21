#!/usr/bin/env bash

function usage {
	programName=$0
	echo "description: use this program to get a weather report for the Pathfinder OpenShift Platform"
	echo "usage: $programName [-m \"email-address\"] [-s \"slack-channel\"]"
	exit 1
}

function resources {
	NODES=""
	for n in ${@}
	do
		NODES="$NODES \"$n\""
        	CLOAD=$(ssh -q ocpadmin@$n "awk '{print \$1, \$2, \$3}' /proc/loadavg")
        	CVOLS=$(ssh -q ocpadmin@$n "sudo df -h | grep openshift.local.volumes | wc -l")
		CVOLS_PAD=$(echo $CVOLS | awk '{printf "%3s",$1}')
        	CSIZE=$(ssh -q ocpadmin@$n "sudo lvdisplay docker-vg/docker-pool | grep 'Allocated pool data'")
		CSIZE_PAD=$(echo $CSIZE | sed -e 's/%//' | awk '{printf "%2.f",$4}')
        	CMETA=$(ssh -q ocpadmin@$n "sudo lvdisplay docker-vg/docker-pool | grep 'Allocated metadata'")
		CMETA_PAD=$(echo $CMETA | sed -e 's/%//' | awk '{printf "%2.f",$3}')
        	CKUBE=$(oc describe node $n | egrep -A 4 'Name:|Allocated resources:|Kubelet Version:' | egrep 'Name:|%|Non-terminated Pods' | sed -e 's/Non-terminated Pods://g' -e 's/Name://g' | perl -p -i -e 's/dmz\n/dmz /g' | perl -p -i -e 's/in total\)\n/ /g' | tr -d '()' | awk '{printf "Node: %s  Pods: %2s  CPU: %3s  Mem: %3s", $1,$2,$4,$8}' | perl -p -i -e 's/\n//')
        	MSG="$MSG $CKUBE Vol: $CVOLS_PAD Data: $CSIZE_PAD% Meta: $CMETA_PAD% Load: $CLOAD \n"
	done

	NSTAT=$(oc get nodes -o go-template="{{range .items}}{{if  eq .metadata.name $NODES}}{{.metadata.name}}{{print \"\t\"}}{{.status.allocatable.cpu}}{{print \"\t\"}}{{.status.allocatable.memory}}{{print \"\n\"}}{{end}}{{end}}")

	PODS=$(oc get pods --all-namespaces -o go-template="{{range .items}}{{if .spec.nodeName}}{{if and (not (eq .status.phase \"Failed\" \"Succeeded\")) (eq .spec.nodeName $NODES)}}{{range .spec.containers}}{{.name}}{{print \"\t\"}}{{.resources.requests.cpu}}{{print \"\t\"}}{{.resources.requests.memory}}{{print \"\n\"}}{{end}}{{end}}{{end}}{{end}}")

	MSG="$MSG\n Total CPU requests:\n"
	TCPU=$(echo "$PODS" | awk -F "\t" 'BEGIN { SUM=0 } {if ($2 ~ "m") SUM+=$2/1000; else SUM+=$2 } END {print SUM}')
	ACPU=$(echo "$NSTAT" | awk -F "\t" 'BEGIN { SUM=0 } {if ($2 ~ "m") SUM+=$2/1000; else SUM+=$2 } END {print SUM}')
	PCPU=$(echo "scale=4;$TCPU/$ACPU*100" | bc | awk '{printf "%2.f",$0}') 
	MSG="$MSG $TCPU / $ACPU ($PCPU%)\n"

	MSG="$MSG\n Total Memory requests:\n"
	TMEM=$(echo "$PODS" | awk -F "\t" 'BEGIN { SUM=0 } {if ($3 ~ "Gi") $3=$3*1024"Mi"; if ($3 ~ "G") $3=$3*1000"M"; if ($3 ~ "Mi") $3=$3*1024"Ki"; if ($3 ~ "M") $3=$3*1000"K"; if ($3 ~ "Ki") $3=$3*1024; if ($3 ~ "K") $3=$3*1000; SUM+=$3} END { print SUM/1024/1024/1024"Gi"}')
	AMEM=$(echo "$NSTAT" | awk -F "\t" 'BEGIN { SUM=0 } {if ($3 ~ "Gi") $3=$3*1024"Mi"; if ($3 ~ "G") $3=$3*1000"M"; if ($3 ~ "Mi") $3=$3*1024"Ki"; if ($3 ~ "M") $3=$3*1000"K"; if ($3 ~ "Ki") $3=$3*1024; if ($3 ~ "K") $3=$3*1000; SUM+=$3} END { print SUM/1024/1024/1024"Gi"}')
	PMEM=$(echo "scale=4;$(echo "$TMEM" | sed -e 's/Gi//')/$(echo "$AMEM" | sed -e 's/Gi//')*100" | bc | awk '{printf "%2.f",$0}')
	MSG="$MSG $TMEM / $AMEM ($PMEM%)\n"

	
}

function post2slack {
slackUrl="https://hooks.slack.com/services/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"
SLACKMSG=$( echo "\n$MSG\n" | sed 's/\\/\\\\/g')
SLACKMSG="\`\`\`$SLACKMSG\`\`\`"

read -d '' payLoad << EOF
{
        "channel": "#${SLACKCHAN}",
        "username": "Weather Report",
        "icon_emoji": ":sunny:",
        "mrkdwn": true,
        "text": "${SLACKMSG}"
}
EOF

#statusCode=$(curl --write-out %{http_code} --silent --output /dev/null -X POST -H 'Content-type: application/json' --data "${payLoad}" ${slackUrl})

statusCode=$(curl -s --write-out %{http_code} -X POST  -H 'Content-type: application/json' --data "${payLoad}" ${slackUrl})
#echo ${payLoad}
#echo ${statusCode}

}

PATH=/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

MSG="Weather Report for: "
DATE=$(date)
MSG="$MSG "$DATE"\n"

#node list
MNODES=$(oc describe nodes -l region=master | grep Name: | awk '{print $2}')
INODES=$(oc describe nodes -l region=infra | grep Name: | awk '{print $2}')
CNODES=$(oc describe nodes -l region=app | grep Name: | awk '{print $2}')
QNODES=$(oc describe nodes -l region=quarantine | grep Name: | awk '{print $2}')

MSG="$MSG\nMaster Nodes:\n"
resources $MNODES 

MSG="$MSG\nInfrastructure Nodes:\n"
resources $INODES 

MSG="$MSG\nCompute Nodes:\n"
resources $CNODES 

if [ -n "$QNODES" ]; then
	MSG="$MSG\nQuarantined Nodes:\n"
	resources $QNODES
fi

MSG="$MSG\nDocker Registry:\n"
POD=$(oc -n default get pods -l deploymentconfig=docker-registry -o name | sed 's#pods/##' | head -n 1)
DR=$(oc -n default exec $POD -- df -h /registry)
MSG="$MSG\n$DR\n"

MSG="$MSG\nMetrics:\n"
POD=$(oc -n openshift-infra get pods -l type=hawkular-cassandra -o name | sed 's#pods/##' | head -n 1)
MT=$(oc -n openshift-infra exec $POD -- df -h /cassandra_data)
MSG="$MSG\n$MT\n"

MSG="$MSG\nTop 10 PVs:\n"
DISK=$(ssh -q ociopf-d-140.dmz "df -h" | grep vguserspace01 | /bin/sort -n -r -k 5 | head -10 | awk '{print $6}'| awk -F '[/]' '{print $4}' )
MSG="$MSG\nPV \t\t USED \t PROJ \t\t\t ADMIN"
for D in $DISK
do
PV=$( echo $D | tr _ - | tr [A-Z] [a-z] )
USED=$(ssh -q ociopf-d-140.dmz "df -h" | grep $D | awk '{print $5}' )
PROJPOD=$(oc get pv $PV | tail -1 | awk '{print $6}')
PROJ=$(echo $PROJPOD | awk -F '[/]' '{print $1}' )
ADMIN=$(oc describe policyBindings -n $PROJ | grep -A2 "RoleBinding\[admin\]" | tail -1 | sed 's/Users://' | tr -d '\t' )
MSG="$MSG\n$PV \t $USED \t\t $PROJPOD \t $ADMIN"
done

MSG="$MSG\n\nLegacy Gluster:\n"
DSPACE=$(ssh -q ocpadmin@ociopf-d-140.dmz "sudo lvdisplay vgdockerspace01 | head -13 | tail -3")
MSG="$MSG\nDocker Pool:\n"
MSG="$MSG$DSPACE\n"

USPACE=$(ssh -q ocpadmin@ociopf-d-140.dmz "sudo lvdisplay vguserspace01 | head -13 | tail -3")
MSG="$MSG\nUser Pool:\n"
MSG="$MSG$USPACE\n"

MSG="$MSG\nPVs Available:\n"
for PV in $(oc get pv | awk '{print $2}' | grep Gi | sort | uniq)
do
  PVAVAIL=$(oc get pv | grep Available | grep $PV | wc -l)
  PVTOTAL=$(oc get pv | grep $PV | wc -l)
  MSG="$MSG$PV $PVAVAIL / $PVTOTAL \n" 
done

NBUILD=$(oc get builds --all-namespaces -o go-template='{{range .items}}{{if or (eq .status.phase "New") (eq .status.phase "Pending")}}{{.metadata.namespace}}/{{.metadata.name}} {{.metadata.creationTimestamp}}{{print "\n"}}{{end}}{{end}}')

if [ ${#NBUILD} != 0 ]; then
	MSG="$MSG\nBuilds in NEW status:\n"
	MSG="$MSG$NBUILD\n"
fi

OPODS=$(oc get pods --all-namespaces -o go-template="{{range .items}}{{if .spec.nodeName}}{{else}}{{if not (eq .status.phase \"Failed\" \"Succeeded\")}}{{.metadata.namespace}}{{print \"/\"}}{{.metadata.name}}{{print \"\n\"}}{{end}}{{end}}{{end}}")

if [ ${#OPODS} != 0 ]; then
	MSG="$MSG\nOrphan Pods:\n"
	MSG="$MSG$OPODS\n"
fi



if [[ $1 == "" ]]
then
	echo -e "$MSG"
else
while getopts ":m:s:h" opt; do
  case ${opt} in
    m) 	MAILTO="$OPTARG"
	MSG="$MSG\n"
	echo -e "$MSG" | /bin/mail -s "Pathfinder Weather Report $DATE" $MAILTO
    ;;
    s) SLACKCHAN="$OPTARG"
	post2slack
    ;;
    h) usage
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done
fi



