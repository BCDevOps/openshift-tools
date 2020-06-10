//
// github-awesomer
//
// Copyright © 2020 Province of British Columbia
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// Created by Shelly Xue Han on 2020-06-04.
//

'use strict';

import Octokit from '@octokit/rest';
import config from '../config';

const octokit = Octokit({
  auth: config.get('github:token'),
});

/**
 * Verify the current login session
 * @param {String} org org of the issue
 */
export const verifyAuth = async org => {
  try {
    console.log('------starting-------');
    const session = await octokit.users.getAuthenticated();
    console.log(`You are using account: ${session.data.login}`);

    // verify GitHub Organization:
    const orgInfo = await octokit.orgs.get({
      org
    });
    console.log(`GitHub Org: ${orgInfo.data.login}`);
  } catch (err) {
    throw err;
  }
};

/**
 * Get user events up to a date (GitHub api returns only up to three months)
 * @param {String} username GitHub username
 * @param {String} expiryDate the date to check up to
 */
export const checkUserEvents = async (username, expiryDate) => {
  try {
    const userInfo = await octokit.activity.listEventsForUser({
      username,
    });

    // Get the latest activity:
    // Note: if no activity for more than three months, there will be no last-modified
    const lastModified = userInfo.headers['last-modified'];
    const date = lastModified ? new Date(lastModified).getTime() : expiryDate;

    // Check for latest activity:
    if (date <= expiryDate) {
      return {
        username,
        expired: true,
      };
    }
    return {
      username,
      expired: false,
    };
  } catch (err) {
    throw err;
  }
};

/**
 * Get list of usernames in the Ops GitHub team
 * @param {String} org GitHub Org to check
 * @param {String} teamName Team name
 */
export const getOpsTeam = async (org, teamName) => {
  try {
    const teamInfo = await octokit.teams.getByName({
      org,
      team_slug: teamName,
    });

    const teamId = teamInfo.data.id;
    const teamMembers = await octokit.teams.listMembers({
      team_id: teamId,
    });

    return teamMembers.data.map(user => user.login);    
  } catch (err) {
    throw err;
  }
};

/**
 * Get list of inactive users
 * @param {String} org GitHub Org to check
 * @param {String} expiryDate the date to check up to
 */
export const getInactiveUsers = async (org, expiryDate) => {
  try {
    let totalUser = 0;
    let inactiveUser = 0;
    const inactiveUsers = [];

    const options = octokit.orgs.listMembers.endpoint.merge({
      org,
    });

    const orgMembers = await octokit.paginate(options);

    // Get event list for all users:

    for (let user of orgMembers) {
      totalUser++;
      const result = await checkUserEvents(user.login, expiryDate);
      if (result.expired) {
        inactiveUser++;
        inactiveUsers.push(result.username);
      }
    }
    return {
      totalUser,
      inactiveUser,
      inactiveUsers,
    };
  } catch (err) {
    throw Error(err);
  }
};

/**
 * Add user to the repo for commenting
 * @param {String} owner org of the issue
 * @param {String} repo repo of the issue
 * @param {String} users target users
 * @param {String} permission default to pull
 */
export const addUserToRepo = async (owner, repo, users, permission = 'pull') => {
  try {
    for (let username of users) {
      await octokit.repos.addCollaborator({
        owner,
        repo,
        username,
        permission: permission,
      });
    }
  } catch (err) {
    throw err;
  }
};

/**
 * Remove user to the repo for commenting
 * @param {String} owner org of the issue
 * @param {String} repo repo of the issue
 * @param {String} users target users
 */
export const removeUserToRepo = async (owner, repo, users) => {
  try {
    for (let username of users) {
      await octokit.repos.removeCollaborator({
        owner,
        repo,
        username,
      });
    }
  } catch (err) {
    throw err;
  }
};


/**
 * Get the GitHub issue comments username
 * @param {String} owner org of the issue
 * @param {String} repo repo of the issue
 * @param {String} issueNumber number of the issue
 */
export const getReactions = async (owner, repo, issueNumber) => {
  try {
    const comments = await octokit.issues.listComments({
      owner,
      repo,
      issue_number: issueNumber,
    });
    return comments.data.map(c => c.user.login);
  } catch (err) {
    throw err;
  }
};

/**
 * Check if GitHub username exist
 * @param {String} username GitHub username
 */
export const checkUserExist = async username => {
  try {
    // check if user exists
    const user = await octokit.users.getByUsername({
      username,
    });
    if (user.status === 200) return 1;
    return 0;
  } catch (err) {
    return 0;
  }
};

/**
 * Add a user to GitHub organization
 * @param {String} username GitHub username
 * @param {String} org GitHub Org
 */
export const addUserToOrg = async (username, org) => {
  try {
    const result = await octokit.orgs.addOrUpdateMembership({
      org,
      username,
    });
    console.log(`Invited user ${username} to ${org} with status ${result.status}`);
  } catch (err) {
    console.error(err);
  }
};

/**
 * Check if user have a membership in an org
 * @param {String} username GitHub username
 * @param {String} org GitHub Org
 */
export const detectUserMembership = async (username, org) => {
  try {
    // check if user in org
    const membership = await octokit.orgs.checkMembership({
      org,
      username,
    });
    if (membership.status === 204) {
      console.log(`${username} in ${org} is ${membership.status}`);
    }
    return 200;
  } catch (err) {
    // no membership:
    if (err.status === 404) {
      return 404;
    }
    console.error(err);
    return 500;
  }
};
