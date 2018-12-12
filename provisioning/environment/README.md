
# Project Categories:
- pathfinder
- sandbox
- spark
- venture
- poc


# Creating a project-set
```
# 1) create input.env


# 2) run script
```
./create2.sh --template=default --category=venture --product=SCJOB '--description=Superior Courts Judiciary Online Booking project' --admin=GovtRyan --team=SCJ
#if `--category` is 'sandbox' or 'poc', then `--template=sandbox`

#apply-quota.sh <template> <namespace> <environment name/type:tools|dev|test|prod>
./apply-quota.sh default ag-devops-lab-tools tools

```