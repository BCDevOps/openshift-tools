#!/usr/bin/env node
require('dotenv').config();
const fs = require('fs-extra');
const Octokit = require('@octokit/rest');

const octokit = Octokit({
  auth: process.env.GITHUB_TOKEN,
});

/**
 * Get user events up to a date (GitHub api returns only up to three months)
 * @param {String} username GitHub username
 * @param {String} expiryDate the date to check up to
 */
const checkUserEvents = async (username, expiryDate) => {
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
      console.log(`@${username}`);
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
const getOpsTeam = async (org, teamName) => {
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
const getInactiveUsers = async (org, expiryDate) => {
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
 * Get the GitHub issue comments username
 * @param {String} owner org of the issue
 * @param {String} repo repo of the issue
 * @param {String} issueNumber number of the issue
 */
const getReactions = async (owner, repo, issueNumber) => {
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
}

// Main:
(async () => {
  const org = process.env.GITHUB_OWNER;
  const file = './output/inactive_users.json';

  try {
    console.log('------starting-------');
    const session = await octokit.users.getAuthenticated();
    console.log(`You are using account: ${session.data.login}`);

    // 1. verify GitHub Organization:
    const orgInfo = await octokit.orgs.get({
      org
    });
    console.log(`GitHub Org: ${orgInfo.data.login}`);

    // TODO: Get users without 2FA:

    // Get users inactive for three months:
    var expiryDate = new Date();
    expiryDate.setMonth(expiryDate.getMonth() - 3);
    console.log(`------Inactive Users since ${expiryDate}-------`);
    const result = await getInactiveUsers(org, expiryDate);

    // filter out the OPS team members:
    const opsTeamMember = await getOpsTeam(org, process.env.OPS_TEAM_NAME);
    const targetUsers = result.inactiveUsers.filter(user => !opsTeamMember.includes(user));

    console.log(`------Total user count in org ${org} is ${result.totalUser}, there are ${result.inactiveUser} inactive users.------`);
    await fs.outputFile(
      file,
      targetUsers,
    );

    // get the users that have not yet replied to the ticket:
    if (process.env.BCDEVOPS_ISSUE_OWNER && process.env.BCDEVOPS_ISSUE_REPO && process.env.BCDEVOPS_ISSUE_ID) {

      const repliedUsers = await getReactions(process.env.BCDEVOPS_ISSUE_OWNER, process.env.BCDEVOPS_ISSUE_REPO, process.env.BCDEVOPS_ISSUE_ID);
      const deleteUsers = targetUsers.filter(user => !repliedUsers.includes(user));
  
      console.log('The users that have replied:');
      console.log(repliedUsers);
      console.log('The users to be removed:');
      console.log(deleteUsers);
    }

  } catch (err) {
    console.error(err);
  }
})();
