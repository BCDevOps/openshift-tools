/**
 * This script imports a CSV file and apply the labels to project sets
 */

'use strict';

const fs = require('fs');
const parse = require('csv-parse');

// Create the parser
const parser = parse({ delimiter: ',', columns: true });

// Use the readable stream api
parser.on('readable', function() {
  let record;
  while ((record = parser.read())) {
    const args = [
      '--as=system:serviceaccount:openshift:bcdevops-admin',
      'label',
      `namespace/${record.namespace}`,
      '--overwrite'
    ];
    for (let label of Object.keys(record)) {
      if (label !== 'namespace') {
        /** @type {string} */
        const value = record[label];
        if (value.length > 0) {
          args.push(`${label}=${record[label]}`);
        } else {
          args.push(`${label}-`);
        }
      }
    }
    console.dir(args);
  }
});

fs.createReadStream(__dirname + '/output/projects.csv').pipe(parser);
