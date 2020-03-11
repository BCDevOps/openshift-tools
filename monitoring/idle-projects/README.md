# Idle Projects Lists

This folder will contain the code for collecting a list of idle projects, as well as dated lists from previous rounds of running said code.

## Purpose

There are orphaned projects that aren't running and don't have active development teams. These projects are taking up resources on the platform without providing any value to anyone.
Our plan is to:
 
1. collect a list of projects which appear to be orphaned
2. inform the community that we will be setting the pods in these projects to "idle" state
3. after a set amount to time (TBD), we will return to these same projects to see which are still idle (the idle state indicates that they are not being touched)
4. reach out to the POs to ask them about the state of these projects
5. for those that provide a response, we will work with them to ensure that these projects are properly handled
6. for those that do not respond, we will spin down the pods to 0
7. after a set amount of time (also TBD), we will archive the projects
8. rinse and repeat on a regular basis (probably with automation later)

## List Generation

The following is a quick command that can be run to gather a list of namespaces that have *problem* pods in them, along with a count of the problem pods:

``` bash
oc get pods --all-namespaces | grep -v -e Completed -e Running -e NAMESPACE | awk '{print $1}' | uniq -c | sort -n
```
