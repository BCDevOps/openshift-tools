#!/usr/bin/env python

import argparse
import json
import subprocess

output = {}

parser = argparse.ArgumentParser(description='OpenShift Inventory')
parser.add_argument('--list', action="store_true", help="List hosts")
parser.add_argument('--host', action="store", help="Get host variables")
args = parser.parse_args()

if ( args.list ):
  p = subprocess.Popen('oc get nodes --no-headers -o custom-columns=NAME:.metadata.name,REGION:.metadata.labels.region', shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
  for line in p.stdout.readlines():
    host,group = line.split()
    output.setdefault(group,{"hosts":[]})
    output[group]['hosts'].append(host)

  print json.dumps(output)

if (args.host):
  print json.dumps({})
