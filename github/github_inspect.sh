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

function_open_license_issue() {
  repo=$1

  check_issue_exist $repo "LICENSE File mising"
  if [ $? -lt 1 ]
  then
    curl -H "Authorization: token ${gitToken}" -H "Content-Type: application/json" -X POST ${githubApiUrl}/repos/${repo}/issues -d '{"title": "LICENSE File mising", "body": "Please note that all repositories in the BCGOV ORG are required to have a LICENSE file"}'
  fi
}

function_open_readme_issue() {
  repo=$1

  check_issue_exist $repo "README File mising"
  if [ $? -lt 1 ]
  then
    curl -H "Authorization: token ${gitToken}" -H "Content-Type: application/json" -X POST ${githubApiUrl}/repos/${repo}/issues -d '{"title": "README File mising", "body": "Please note that all repositories in the BCGOV ORG should have a README file"}'
  fi
}

function_open_admin_issue() {
  repo=$1

  check_issue_exist $repo "ADMIN User mising"
  if [ $? -lt 1 ]
  then
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

function org_inactive_members() {
  org=$1
  cnt=1
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
          mevents=0
          x=$(curl -s -H "Authorization: token ${gitToken}" ${githubApiUrl}/users/${mName}/events/orgs/${org}|grep -i created | sed s/\"created_at\"://g | sed s/[\",ZT\:\-]//g)
          sixMonthAgo=$(date -v-6m "+%Y%m%d%H%M%S")
          userIsActive=0
          for date in $x
          do 
            mevents=1
            if [ $date > $sixMonthAgo ] 
            then
              userIsActive=1
              break
            fi
          done
          if [ $mevents -gt 0 ] 
          then
            if [ $userIsActive -lt 0 ]
            then
              echo "${mName} - INACTIVE - LAST EVENT MORE THAN SIX MONTH AGO"
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
githubApiUrl="https://api.github.com"
orglist=("bcgov" "bcgov-c" "BCDevOps" "BCDevExchange")

for org in "${orglist[@]}"
do
  echo "Organization: $org"
  repolist=()
  get_org_repos $org $gitToken
  echo "No of repos in bcgov: ${#repolist[@]}"
  for rp in "${repolist[@]}"
  do
    hasLic=`curl -s -H "Authorization: token $gitToken" ${githubApiUrl}/repos/${rp}/contents/|grep -i license|wc -l`
    if [ $hasLic -lt 1 ] 
    then
      echo "${rp} - NO LICENSE FILE!"
    fi
    hasRme=`curl -s -H "Authorization: token $gitToken" ${githubApiUrl}/repos/${rpname}/contents/|grep -i readme|wc -l`
    if [ $hasRme -lt 1 ] 
    then
      echo "${rp} - NO README FILE!"
    fi
    check_repo_admin_user $rp
    if [ $? -lt 1 ] 
    then
      echo "${rp} - NO ADMIN USER!"
    fi
  done
done
org_inactive_members "bcgov-c"
org_inactive_members "bcgov"
