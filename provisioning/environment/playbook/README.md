# Purpose

This playbook will create / delete the namespaces for a bcgov pathfinder project set. Four namespaces, `tools`, `dev`, `test`, `prod` will be created as a standard set from request. (this playbook is based on the https://github.com/BCDevOps/devops-platform-workshops provisiong abp)

## Requirements

- ansible
- `oc` binary on the local host, already logged into the target cluster
- permissions to create projects as the service account

## Instructions

1. Edit `vars.yaml` to modify:

- The list of environments to create
- The admin user list (by GitHub ID)
- The project metadate (display_name, team_name, product_name, project_description, product_lead_email, product_owner_email)
- The project name when delete a project set

2. Run the playbook with a desired action (create/delete)

``` bash
ansible-playbook workshop_projects.yaml -e action=create
```

*Note* The deletion process will take some time.
