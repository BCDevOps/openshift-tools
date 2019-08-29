## Create Project Set

When a valid request (as decribed above) is to be actioned by a member of the DevOps platform team, the following steps will be executed:
 
* (if necessary) clone/pull latest code from `https://github.com/BCDevOps/openshift-tools`
* with the information in the prior section on-hand, execute the script at `provisioning/enivironment/shell/create-env.sh`
* complete the prompts, providing information from request as appropriate

The script will output a friendly "welcome" message to the console that can be copied into an email to the user who will be the owner of the project set that was just created.

Note the welcome message is based on a template file, `onboarding_message_template.txt` that lives alongside `create-env.sh`.
