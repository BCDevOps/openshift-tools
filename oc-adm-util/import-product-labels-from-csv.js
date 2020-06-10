/**
 * This script imports a CSV file and apply the labels+annotations to project sets
 */

'use strict';

const fs = require('fs');
const parse = require('csv-parse');
const { spawnSync } = require('child_process');

// Create the parser
const parser = parse({ delimiter: ',', columns: true });

// Skip labels/annotation when applying changes:
const ignoreFields = [
  'namespaces',
  'environments',
  'product-owner',
  'product-lead'
];

// The fileds to apply for labels and annotations:
const labelFields = [
  'name',
  'category',
  'mcio',
  'miso',
  'mpo',
  'bus_org_code',
  'bus_org_unit_code',
  'product',
  'project_type',
  'team',
  'expiry',
];

const annotationFields = [
  'product-owner',
  'product-lead',
];

// Use the readable stream api
parser.on('readable', function() {
  let record;
  while ((record = parser.read())) {
    const projectSet = record.namespaces.split(',');
    const projectName = record.name;

    // backup:
    const getProjectArgs = [
      '--as=system:serviceaccount:openshift:bcdevops-admin',
      'get',
      `namespace/${projectSet[0]}`,
      '-o',
      'json'
    ];
    const proc = spawnSync('oc', getProjectArgs);
    fs.writeFileSync(`output/backup-${projectName}.json`, proc.stdout);

    // update:
    const labelArgs = [];
    const annotationArgs = [];

    for (let fieldName of Object.keys(record)) {
      // get all labels to add:
      if (labelFields.includes(fieldName)) {
        /** @type {string} */
        const value = record[fieldName];
        if (value.length > 0) {
          labelArgs.push(`${fieldName}=${value}`);
        } else {
          labelArgs.push(`${fieldName}-`);
        }
      }

      // get all annotations to add:
      // TODO: Skipping for now
      if (annotationFields.includes(fieldName)) {
        /** @type {string} */
        const value = record[fieldName];
        if (value.length > 0) {
          annotationArgs.push(`${fieldName}=${value}`);
        } else {
          // do not remove annotations:
          annotationArgs.push(`${label}-`);
        }
      }
    }

    projectSet.forEach(namespace => {
      const args = [
        '--as=system:serviceaccount:openshift:bcdevops-admin',
        'label',
        `namespace/${namespace}`,
        '--overwrite'
      ];

      const fullArgs = args.concat(labelArgs);
      console.dir(fullArgs);
      const proc = spawnSync('oc', fullArgs);
      if (proc.stderr) {
        console.log(Error(proc.stderr));
      }
      console.log(`Info: ${proc.stdout}`);
    });
  }
});

fs.createReadStream(__dirname + '/output/products.csv').pipe(parser);
