"use strict";

/**
oc get project -o json | jq -M '[.items[] | .metadata.labels + {"namespace": .metadata.name}]' > projects.json 
jq -r '(map(keys) | add | unique | map(select( . | startswith("openshift.io") | not))) as $cols | map(. as $row | $cols | map($row[.])) as $rows | $cols, $rows[] | @csv' projects.json > projects.csv
 */

 /**
  * List Labels
  jq -r 'map(keys) | add | unique | map(select( . | startswith("openshift.io") | not))' projects.json
  */
const parse = require('csv-parse')

// Create the parser
const parser = parse({
  delimiter: ':'
})
