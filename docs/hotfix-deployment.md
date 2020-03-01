# Apply for Postgraduate Teacher Training - Hotfix Deployment

## Purpose

This document describes the process of manually deploying a hotfix

### When should this process be used?

Normally deployments to the `staging`, `sandbox` and `production` environments
happen on a daily (or more frequent) basis and include all changes that
have been merged into master. A hotfix is a more urgent deployment
containing typically just one pull request. A hotfix should be performed
when:

1. The fix is urgent.
2. There are other changes already merged into master since the last
   deployment that we don't want to deploy yet perhaps because they are
   not fully tested.

## Instructions

We assume that we begin in a situation like this:

```
master        X------1-----2
               \    /     /
feature1        ----     /
                \       /
feature2         -------
```

Since last deployed at `X` we've merged two additional features into
`master`. We urgently need to create a fix that does not include
features 1 and 2, we just want everything up to `X`.

### Minimum steps that would work...

1. Fetch `master` to your local machine and create a branch from `X`
   (not `HEAD` as we normally would).
2. Implement the fix locally raise a PR and get it approved in the
   normal way. Test it locally or using the Heroku review app that will
   be automatically created.
3. Deploy the `hotfix` branch using the normal deployment procedure
   (except picking `HEAD` of the `hotfix` branch rather than a specific
   SHA on `master` as we normally do).
4. Merge the `hotfix` branch back to `master`.


Issues that are not addressed here:

- What if we had more than one hotfix on the go at a time? The main
  problem here would be multiple hotfix branches. If we can stick to
  just a single hotfix branch then we should be fine. That branch could
  contain more than one actual fix if needed. We would need to make sure
  that if a hotfix is initiated that the whole team knows about it.
- What if we deployed normally again to production after branching
  `hotfix` but before it was merged? If this happened then it would
  indicate a failure of communication or a hotfix just taking a long
  time. In this case it might make more sense to roll the hotfix into
  the regular release as a normal change and ship it as normal.


## References

If you Google something like 'git branching strategy for hotfixes' you
will find that the top hits point to Gitflow, a popular branching model
that defines a set of conventions and covers developer feature branches,
regular releases and hotfixes. It's fairly heavy compared to our current
model and there are alternatives, four of them are reviewed in this
article:

https://medium.com/@patrickporto/4-branching-workflows-for-git-30d0aaee7bf

If we want to stay as close as possible to the model that we have at the
moment we should avoid Gitflow, in particular the idea of having two
main branches. This article describes something close to the minimum
steps I've outlined above:

https://www.endoflineblog.com/gitflow-considered-harmful


