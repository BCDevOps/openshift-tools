/**
 * This script generates a CSV file of all project sets with labels and business annotations from the cluster
 */

'use strict';

const fs = require('fs');
const { spawnSync } = require('child_process');
// Get list of namespaces with name and environment labels:
const proc = spawnSync('oc', [
  'get',
  'namespace',
  '--selector=name,environment',
  '--sort-by={.metadata.name}',
  '--output=json',
  '--no-headers=true'
]);
const namespaces = JSON.parse(proc.stdout);

// Project set and list of attributes:
const products = new Map();
const headers = new Map();

/**
 * Parse labels and group namespaces by project set:
 * @param {String} namespace name of a namespace
 * @param {Object} resource metadata of a namespace
 */
function update(namespace, resource) {
  const annotations = resource.metadata.annotations;
  const labels = resource.metadata.labels;
  const name = resource.metadata.labels['name'];
  const product = products.get(name) || {};

  headers.set('name', true);
  headers.set('environments', true);
  headers.set('namespaces', true);

  product.name = name;
  product.namespaces = product.namespaces || [];
  product.namespaces.push(namespace);
  product.environments = product.environments || [];
  product.environments.push(labels.environment);

  // Collect all labels, other than 'environment':
  for (let label of Object.keys(labels)) {
    if (label != 'environment') {
      headers.set(label, true);
      if (product[label] == null) {
        product[label] = labels[label];
      } else {
        if (product[label] != labels[label]) {
          throw new Error(
            `Expected '${product[label]}' but found '${labels[label]}' (namespace:${namespace}, label:'${label}')`
          );
        }
      }
    }
  }
  // Collect the annotations for product owner and lead:
  for (let annotation of Object.keys(annotations)) {
    if (annotation == 'product-owner' || annotation == 'product-lead') {
      headers.set(annotation, true);
      if (product[annotation] == null) {
        product[annotation] = annotations[annotation];
      } else {
        if (product[annotation] != annotations[annotation]) {
          throw new Error(
            `Expected '${product[annotation]}' but found '${annotations[annotation]}' (namespace:${namespace}, annotation:'${annotation}')`
          );
        }
      }
    }
  }
  products.set(name, product);
}

for (let resource of namespaces.items) {
  console.log(`Processing ${resource.metadata.name}`);
  update(resource.metadata.name, resource);
}

// populate column names:
let colIndex = 0;
for (let header of headers.keys()) {
  if (colIndex == 0) {
    fs.writeFileSync('output/products.csv', `"${header}"`, {
      encoding: 'utf8',
      flag: 'w'
    });
  } else {
    fs.writeFileSync('output/products.csv', `,"${header}"`, {
      encoding: 'utf8',
      flag: 'a'
    });
  }
  colIndex++;
}

// populate data:
for (let product of products.values()) {
  fs.writeFileSync('output/products.csv', '\n', {
    encoding: 'utf8',
    flag: 'a'
  });
  colIndex = 0;
  for (let header of headers.keys()) {
    if (colIndex == 0) {
      fs.writeFileSync('output/products.csv', `"${product[header] || ''}"`, {
        encoding: 'utf8',
        flag: 'a'
      });
    } else {
      fs.writeFileSync('output/products.csv', `,"${product[header] || ''}"`, {
        encoding: 'utf8',
        flag: 'a'
      });
    }
    colIndex++;
  }
}
