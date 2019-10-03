'use strict';

/**
oc get project -o json | jq -M '[.items[] | .metadata.labels + {"namespace": .metadata.name}]' > output/projects.json
jq -r '(map(keys) | add | unique | map(select( . | startswith("openshift.io") | not))) as $cols | map(. as $row | $cols | map($row[.])) as $rows | $cols, $rows[] | @csv' output/projects.json > output/projects.csv
 */

/**
  * List Labels
  jq -r 'map(keys) | add | unique | map(select( . | startswith("openshift.io") | not))' output/projects.json
  */

