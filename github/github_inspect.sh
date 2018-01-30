#!/bin/bash

# Define functions

function get_org_repos() {
  org=$1
  cnt=1
  while [ $cnt -gt 0 ]
  do
    repolst=$(curl -s -H "Authorization: token ${gitToken}" ${githubApiUrl}/orgs/${org}/repos?per_page=100\&page=$cnt|grep full_name | awk 'NR>0 {print $2}')
    rpcnt=${#repolst}
    if [ $rpcnt -gt 0 ]
    then
      cnt=$[$cnt+1]
      for rp in $repolst
      do 
        rp1=${rp%\",}
        rpname=${rp1#\"}
        repolist+=( $rpname)
      done
    else 
     cnt=0
    fi
  done
}

function check_repo_admin_user {
  repo=$1
  returnVal=0
  admincnt=$(curl -s -H "Authorization: token ${gitToken}" ${githubApiUrl}/repos/${repo}/collaborators|grep admin | grep true | wc -l)
  if [ $admincnt -gt 0 ] 
  then
    returnVal=1
  else
    admincnt=$(curl -s -H "Authorization: token ${gitToken}" ${githubApiUrl}/repos/${repo}/teams|grep -i permission|grep -i admin|wc -l)
    if [ $admincnt -gt 0 ] 
    then
      returnVal=1
    fi
  fi
  return $returnVal
}

function open_license_issue() {
  repo=$1

  check_issue_exist $repo "LICENSE File mising"
  if [ $? -lt 1 ]
  then
    echo "> Creating issue"
    curl -H "Authorization: token ${gitToken}" -H "Content-Type: application/json" -X POST ${githubApiUrl}/repos/${repo}/issues -d '{"title": "LICENSE File mising", "body": "Please note that all repositories in the BCGOV ORG are required to have a LICENSE file"}'
  fi
}

function open_readme_issue() {
  repo=$1

  check_issue_exist $repo "README File mising"
  if [ $? -lt 1 ]
  then
    echo "> Creating issue"
    curl -H "Authorization: token ${gitToken}" -H "Content-Type: application/json" -X POST ${githubApiUrl}/repos/${repo}/issues -d '{"title": "README File mising", "body": "Please note that all repositories in the BCGOV ORG should have a README file"}'
  fi
}

function open_admin_issue() {
  repo=$1

  check_issue_exist $repo "ADMIN User mising"
  if [ $? -lt 1 ]
  then
    echo "> Creating issue"
    curl -H "Authorization: token ${gitToken}" -H "Content-Type: application/json" -X POST ${githubApiUrl}/repos/${repo}/issues -d '{"title": "ADMIN User mising", "body": "Please assign an Admin user to the repository. Thanks."}'
  fi
}

function check_issue_exists() {
  repo=$1
  issueTopic=$2
  returnVal=0
  issueList=$(curl -s -H "Authorization: token ${gitToken}" ${githubApiUrl}/repos/${repo}/issues|grep -i title| grep "$issueTopic")
  icnt=${#issueList}
  if [ $icnt -gt 0 ] 
  then 
    returnVal=1
  fi
  return returnVal
}

function remove_user_from_org() {
  org=$1
  user=$2
  curl -s -H "Authorization: token ${gitToken}" -X DELETE ${githubApiUrl}/orgs/${org}/members/${user}
}

function add_user_to_bcgov_read() {
  org=$1
  user=$2
  curl -s -H "Authorization: token ${gitToken}" -X PUT ${githubApiUrl}/teams/${bcgovReadTeamID}/members/${user}
}

function org_inactive_members() {
  org=$1
  cnt=1
  sixMonthAgo=$(date -v-6m "+%Y%m%d%H%M%S")
  while [ $cnt -gt 0 ]
  do
    memberlst=$(curl -s -H "Authorization: token ${gitToken}" ${githubApiUrl}/orgs/${org}/members?per_page=100\&page=${cnt}|grep login)
    mcnt=${#memberlst}
    if [ $mcnt -gt 0 ]
    then
      cnt=$[$cnt+1]
      for member in $memberlst
      do 
        if [ ! "$member" == "\"login\":" ]
        then
          mTmpName=${member%\",}
          mName=${mTmpName#\"}
          if [ $debug -gt 0 ]
          then
            echo ">> ${org} member ${mName}"
          fi
          #Get user creation date
          myCDate=$(curl -s -H "Authorization: token ${gitToken}" ${githubApiUrl}/users/${mName} | grep "created_at" | sed s/\"created_at\"://g | sed s/[\",ZT\:\-]//g)
          if [ $debug -gt 0 ]
          then
            echo ">> ${org} member ${mName} created $myCDate"
          fi
          if [ $myCDate -lt $sixMonthAgo ] 
          then
            #Get users events  
            mevents=0
            myEDates=$(curl -s -H "Authorization: token ${gitToken}" ${githubApiUrl}/users/${mName}/events|grep -i created | sed s/\"created_at\"://g | sed s/[\",ZT\:\-]//g)
            eventcnt=${#myEDates}
            if [ $debug -gt 0 ]
            then
              echo ">> ${org} member ${mName} has ${eventcnt} event dates: ${myEDates}"
            fi
            userIsActive=0
            if [ $eventcnt -lt 1 ] 
            then
               echo "${org}/${mName} - NO Events for user, user created $myCDate"
            else
              for date in $myEdates
              do 
                mevents=1
                if [ $date -ge $sixMonthAgo ] 
                then
                  userIsActive=1
                  break
                fi
              done
              if [ $mevents -gt 0 ] 
              then
                if [ $userIsActive -lt 0 ]
                then
                  echo "${org}/${mName} - INACTIVE - LAST EVENT MORE THAN SIX MONTH AGO"
                  if [ "$org" == "bcgov-c" ]
                  then 
                    #Move user to BCGOV_READ
                    if [ $dryrun -eq 0 ] 
                    then
                      echo "Move user ${mName} to ${org}/BCGov (Read)"
                      add_user_to_bcgov_read $org $mName
                    fi
                  fi
                  if [ "$org" == "bcgov" ]
                  then
                    #Remove user from bcgov-c org
                    if [ $dryrun -eq 0 ] 
                    then
                      echo "Remove user ${mName} from ${org}"
                      remove_user_from_org $org $mName
                    fi
                  fi
                fi
              fi
            fi
          fi
        fi
      done
    else 
     cnt=0
    fi
  done
}


# MAIN Apps

gitToken=$1
if [ $# -gt 1 ] 
then 
  dryrun=1
  echo "Dry-run Mode"
else 
  dryrun=0
fi
githubApiUrl="https://api.github.com"
orglist=("bcgov" "bcgov-c" "BCDevOps" "BCDevExchange")
bcgovReadTeamID=1341131
debug=0

for org in "${orglist[@]}"
do
  sleep 30
  echo "Organization: $org"
  repolist=()
  get_org_repos $org $gitToken
  echo "No of repos in ${org}: ${#repolist[@]}"
  for rp in "${repolist[@]}"
  do
    hasLic=$(curl -s -H "Authorization: token $gitToken" ${githubApiUrl}/repos/${rp}/contents|grep -i license|wc -l)
    if [ $debug -gt 0 ] 
    then
      echo ">> CURL LIC: $hasLic"
    fi
    if [ $hasLic -lt 1 ] 
    then
      echo "${rp} - NO LICENSE FILE!"
      if [ $dryrun -eq 0 ] 
      then
        open_license_issue $rp
      fi
    fi
    hasRme=$(curl -s -H "Authorization: token $gitToken" ${githubApiUrl}/repos/${rp}/contents|grep -i readme|wc -l)
    if [ $debug -gt 0 ] 
    then
      echo ">>CURL RME: $hasRme"
    fi
    if [ $hasRme -lt 1 ] 
    then
      echo "${rp} - NO README FILE!"
      if [ $dryrun -eq 0 ] 
      then 
        open_readme_issue $rp
      fi
    fi
    check_repo_admin_user $rp
    if [ $? -lt 1 ] 
    then
      echo "${rp} - NO ADMIN USER!"
      if [ $dryrun -eq 0 ] 
      then
        open_admin_issue $rp
      fi
    fi
  done
done
sleep 30
echo "Check users in bcgov-c"
org_inactive_members "bcgov-c"
sleep 30
echo "Check users in bcgov"
org_inactive_members "bcgov"
