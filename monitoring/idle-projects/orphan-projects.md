# Potential Orphan Projects

This list is to be a curated list of all potential orphan projects that we are currently investigating.

- March 3, 2020 there was a network reset on the platform.  All running pods were required to have been restarted since that day (or expect them to be non-functional)  All pods should be 12d old or less to be considered functional.

- working my way from last to first in the following list that was generated on March 12, 2020:

``` bash
cat bad-pods.lst | sort -hk 6
```

# Initial list

- [ ] wyck1k (COR-DYN) - tools pods errored, pods in dev/test/prod older than March 3
- [ ] whamor (ATWORK) - tools/dev/test/prod pods older than March 3, multiple crashlooping pods
- [ ] *rtb-dms* (Dispute Management System) - project details not up to date, pods older than 30 days, multiple crashlooping pods.
- [ ] *rejspb* (DSLab-OCWA) - dev pods older than 30 days, no deployments to any other environment.
- [ ] range-myra - likely ok, but team needs to be asked to look at tools namespace.
- [ ] r5sc6a (RSI-Legacy) - no prod deployments, pods in dev/test running for more than 40 days
- [ ] qjtfov (Human Rights Tribunal) - tools/dev pods older than 30 days, no test/prod deployments
- [ ] pbuo5q (USER-ID-MGMT) - all pods over 40 days old, multiple crashlooping
- [ ] 