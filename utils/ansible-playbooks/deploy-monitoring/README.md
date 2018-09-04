# OCP Monitor script

## How to deploy

Check out this code to your IDIR_A account on the primary master.

Ensure you are logged in to the oc command by running

```
oc get nodes
```

If not, copy the oc login command from [LAB](https://console.lab.pathfinder.gov.bc.ca:8443/console/command-line) or [PROD](https://console.pathfinder.gov.bc.ca:8443/console/command-line)

Create a file called `.vaultpass` in this folder with the password from the team KeePass under MCS - OpenShift -> Ansible Vault Password

Run the playbook to deploy the monitoring crons

```
ansible-playbook --extra-vars cluster=lab deploy.yaml
```

Set the cluster to either `lab` or `prod` to load in the correct variables file.

You will be prompted for your IDIR_A password.

## Editing vault secrets

Vault files can be edited with

```
ansible-vault edit vault/prod.yaml
```
