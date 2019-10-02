"use strict";

const fs = require('fs');
const { spawn, spawnSync } = require('child_process');


const process = spawn('oc', ['get', 'namespace', '-l','!name', '-o', 'custom-columns=NAME:.metadata.name', '--no-headers=true'])

const lineReader = require('readline').createInterface({
  input: process.stdout
});

lineReader.on('line', function (namespace) {
  let environment = null;
  let name = null;
  for (let suffix of ['deploy', 'sandbox', 'dev', 'test', 'prod', 'tools']){
    if (namespace.endsWith(`-${suffix}`)){
      environment=suffix;
      name=namespace.substring(0, namespace.length - environment.length - 1)
      break;
    }
  }
  if (name!=null){
    console.log(`Updating ${namespace}`);
    /** @type {string[]} */
    const args = ['--as=system:serviceaccount:openshift:bcdevops-admin', 'label', '--overwrite', `namespace/${namespace}`];
    const labels =[`name=${name}`, `environment=${environment}`];
    args.push(...labels);
    const proc = spawnSync('oc', args, {encoding:'utf8'});
    if (proc.status != 0){
      throw new Error(JSON.stringify({namespace, labels, stderr:proc.stderr, stdout:proc.stdout, status:proc.status}))
    }
  }
});