# How to: do a hotfix deployment

## Purpose

This document describes the process of manually deploying a hotfix.

### When should this process be used?

Normally deployments to the `staging`, `sandbox` and `production` environments
happen on a daily (or more frequent) basis and include all changes that
have been merged into main. A hotfix is a more urgent deployment
containing typically just one pull request. A hotfix should be performed
when:

1. The fix is urgent.
2. There are other changes already merged into main since the last
   deployment that we do not want to deploy yet perhaps because they are
   not fully tested.

## Instructions

We assume that we begin in a situation like this:

```
main          ---D--------x-----x--------------x--->
                  \      /     / \            /
feature1           -x-x-x     /   \          /
                   \         /     \        /
feature2            --x-x-x-x       \      /
                                     \    /
feature3                              -x-x
```

Since last deployed at `D` we've merged two additional features into
`main`. We urgently need to create a fix that does not include
features 1, 2 and 3, we just want everything up to `D`.

### Instructions

1. Inform the team that a hotfix is being prepared by posting a new
   thread in Slack to #twd_apply.
2. Fetch `main` to your local machine and create a branch called
   `hotfix` from the last deployed commit (not `HEAD` as we normally
   would). You can specify the last deployed commit using its SHA and
   find out which SHA to use on the
   [ops dashboard](https://apply-ops-dashboard.herokuapp.com/) - just
   look for the current production version. Push the new branch to Github.

  ```
  $ git fetch origin main
  $ git checkout -b hotfix <sha-from-ops-dashboard>
  $ git push origin hotfix
  ```

3. Implement the fix locally, raise a PR and get it approved in the
   normal way. Test it locally or using the Heroku review app that is
   automatically created.
4. After the PR is approved DO NOT MERGE IT to `main` straight away.
   First deploy the `hotfix` branch using the [normal deployment
   procedure](deployment.md) (except picking `HEAD` of the
   `hotfix` branch rather than a specific SHA on `main` as we normally
   do).
5. Merge the `hotfix` branch back to `main`. At this point the `hotfix`
   branch should be automatically deleted.

Here is an example of the process where the last 'normal' deployment was
at `D` and the hotfix was deployed at `H`. After the `hotfix` branch is
merged back into `main` it's back to business as usual.

```
hotfix             ------------------------------x-x-x-H
                  /                                     \
main          ---D--------x-----x--------------x----------->
                  \      /     / \            /
feature1           -x-x-x     /   \          /
                   \         /     \        /
feature2            --x-x-x-x       \      /
                                     \    /
feature3                              -x-x
```

### Notes
- We always use the name `hotfix` to enforce the rule that we only
  ever have one hotfix branch at a time.
- When starting a hotfix it's important that the rest of the team knows
  about it so that nobody else starts any other kind of deploy until
  the hotfix is complete and merged back into `main`.
- Pushing the new `hotfix` branch to Github at the start of the
  process (before any fix commits are made) acts as a signal to other
  developers/systems that a hotfix is in progress.

## References

If you Google something like 'git branching strategy for hotfixes' you
will find that the top hits point to Gitflow, a popular branching model
that defines a set of conventions and covers developer feature branches,
regular releases and hotfixes:

https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow

Gitflow is fairly heavy compared to our current model and there are
alternatives, four of them are reviewed in this article:

https://medium.com/@patrickporto/4-branching-workflows-for-git-30d0aaee7bf

For now we have chosen to avoid Gitflow, in particular the idea of
having two main branches. This article describes something close to the
process that we are following:

https://www.endoflineblog.com/gitflow-considered-harmful
