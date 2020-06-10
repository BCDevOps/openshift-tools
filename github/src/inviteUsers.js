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

import { checkUserExist, detectUserMembership, addUserToOrg } from './utils/github';

/**
 * Invite GitHub users
 * @param {String} inputFile file with list of usernames
 * @param {String} org GitHub Org
 */
export const inviteUsersToOrg = async (inputFile, org) => {
  try {
    // read from the username list:
    const input = await fs.readFile(inputFile);
    const users = input.toString().split("\n");

    // if user exists, check membership, and invite
    users.forEach(async i => {
      const exist = await checkUserExist(i);
      if (exist) {
        const membershipStatus = await detectUserMembership(i, org);
        if (membershipStatus === 404) await addUserToOrg(i, org);
      } else {
        console.warn(`-------------------User ${i} doesn't exist-----------`);
      }
    })
  } catch (err) {
    console.error(err);
  }
};
