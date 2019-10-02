"use strict";
const fs = require('fs');
const { spawn, spawnSync } = require('child_process');
const proc = spawnSync('oc', ['get', 'namespace', '--selector=name,environment', '--sort-by={.metadata.name}', '--output=json', '--no-headers=true'])
const namespaces = JSON.parse(proc.stdout);

const products = new Map();
const headers = new Map();

function update(namespace, resource){
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

  for (let label of Object.keys(labels)){
    if (label != 'environment'){
      headers.set(label, true);
      if (product[label] == null){
        product[label] = labels[label];
      }else{
        if (product[label] != labels[label]){
          throw new Error(`Expected '${product[label]}' but found '${labels[label]}' (namespace:${namespace}, label:'${label}')`)
        }
      }
    }
  }
  products.set(name, product);
  //Object.assign(current, resource.metadata.labels);
}

for (let resource of namespaces.items){
  console.log(`Processing ${resource.metadata.name}`)
  update(resource.metadata.name, resource)
}

//console.dir(headers);
//fs.writeFileSync('products.json', JSON.stringify(Array.from(products.values())), {encoding:'utf8'});
let colIndex = 0;
for (let header of headers.keys()){
  if (colIndex==0){
    fs.writeFileSync('products.csv', `"${header}"`, {encoding:'utf8', flag:'w'});
  }else{
    fs.writeFileSync('products.csv', `,"${header}"`, {encoding:'utf8', flag:'a'});
  }
  colIndex++;
}
//fs.writeFileSync('products.csv', '\n', {encoding:'utf8'});

for (let product of products.values()){
  fs.writeFileSync('products.csv', '\n', {encoding:'utf8', flag:'a'});
  colIndex=0;
  for (let header of headers.keys()){
    if (colIndex==0){
      fs.writeFileSync('products.csv', `"${product[header] || ''}"`, {encoding:'utf8', flag:'a'});
    }else{
      fs.writeFileSync('products.csv', `,"${product[header] || ''}"`, {encoding:'utf8', flag:'a'});
    }
    colIndex++;
  }
}