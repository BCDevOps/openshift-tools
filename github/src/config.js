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

import dotenv from 'dotenv';
import nconf from 'nconf';
import minimist from 'minimist';

const env = process.env.NODE_ENV || 'development';

if (env === 'development') {
  dotenv.config();
}

/**
 * These settings contain sensitive information and should not be
 * stored in the repo. They are extracted from environment variables
 * and added to the config.
 */

// overrides are always as defined
nconf.overrides({
  environment: env,
  // TODO: better ways for action input
  // actions: minimist(process.argv.slice(2)),
  actions: process.env.USER_ACTION,
  exception: {
    opsTeam: process.env.OPS_TEAM_NAME,
    opsUser: process.env.EXCLUDE_USER,
  },
  github: {
    token: process.env.GITHUB_TOKEN,
    owner: process.env.GITHUB_OWNER,
  },
  ghIssue: {
    owner: process.env.NOTIFICATION_ISSUE_OWNER,
    repo: process.env.NOTIFICATION_ISSUE_REPO,
    id: process.env.NOTIFICATION_ISSUE_ID,
  },
});

// // if nothing else is set, use defaults. This will be set if
// // they do not exist in overrides or the config file.
// nconf.defaults({
//   appUrl: process.env.APP_URL || `http://localhost:${process.env.PORT}`,
// });

export default nconf;
