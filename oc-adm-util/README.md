# openshift admin utilities:
- Export a list of projects running on the cluster to CSV file, together with all the labels from project metadata.
- Import updated status of project metadata and apply to each project on the cluster.

### Install:
```
cd oc-adm-util
npm i
oc login <token-from-openshift-console>
```

### export and import metadata of OpenShift project sets:
```
// export to csv file:
npm run export-products

// update namespaces from the csv file:
npm run update-product-labels
```

Result is saved in ./output
