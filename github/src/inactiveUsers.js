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

import config from './config';
import { getInactiveUsers, getOpsTeam, addUserToRepo, removeUserToRepo, getReactions } from './utils/github';

/**
 * Get the GitHub issue comments username
 * @param {String} org org of the issue
 * @param {String} repo repo of the issue
 * @param {String} issueNumber number of the issue
 * @param {String} outputFile path to output
 */
export const notifyInactiveUsers = async (org, outputFile) => {
  try {
    // TODO: Get users without 2FA:

    // Get users inactive for three months:
    var expiryDate = new Date();
    expiryDate.setMonth(expiryDate.getMonth() - 3);
    const result = await getInactiveUsers(org, expiryDate);
    
    // filter out the OPS team members:
    const opsTeamMember = await getOpsTeam(org, config.get('exception:opsTeam'));
    const excludingUser = config.get('exception:opsUser');
    const targetUsers = result.inactiveUsers.filter(user => !opsTeamMember.includes(user) && user !== excludingUser);
    
    // Print out results:
    console.log(`------Total user count in org ${org} is ${result.totalUser}, there are ${result.inactiveUser} inactive users.------\n`);
    console.log(`------Inactive Users since ${expiryDate}-------`);
    targetUsers.forEach(u => console.log(`@${u}`));

    await fs.outputFile(
      outputFile,
      targetUsers,
    );

    // TODO: move this outside
    const action = config.get('actions');
    const issueOrg = config.get('ghIssue:owner');
    const issueRepo = config.get('ghIssue:repo');
    const issueId = config.get('ghIssue:id');

    // Manage target users access to the private notification repo:
    if (action && issueRepo) {
      if (action === 'add') {
        console.log(`Adding user to notification repo at ${issueRepo}`);
        await addUserToRepo(org, issueRepo, targetUsers);
        console.log('All users added.');
      } else if (action === 'remove') {
        console.log(`Removing users to notification repo at ${issueRepo}`);
        await removeUserToRepo(org, issueRepo, targetUsers);
        console.log('All users removed.');
      } else {
        console.log('Action not matching');
      }
    }

    // get the users that have not yet replied to the ticket:
    if (issueOrg && issueRepo && issueId) {
      console.log(`Check on target users response at ${issueOrg} - ${issueRepo} - ${issueId}`);

      const repliedUsers = await getReactions(issueOrg, issueRepo, issueId);
      const deleteUsers = targetUsers.filter(user => !repliedUsers.includes(user));
  
      console.log('The users that have replied:');
      console.log(repliedUsers);
      console.log('The users to be removed:');
      console.log(deleteUsers);
    }
  } catch (err) {
    throw err;
  }
}
