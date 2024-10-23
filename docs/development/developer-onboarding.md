# Developer On-boarding

## Purpose

This document describes the on-boardng steps for new Developers when they join the team.

## You can request access to the following by asking in the #digital-tools-support slack channel

- [DfE-Digital](https://github.com/DFE-Digital) GitHub group access. Once you're added to the BAT (Becoming a Teacher) team you will have access to all repos. Ours are [Find](https://github.com/DFE-Digital/find-teacher-training) and [Apply](https://github.com/DFE-Digital/apply-for-teacher-training)
- [Sentry access](https://sentry.io/auth/login/dfe-teacher-services/)

## DevOps steps

### Getting familiar with AKS

You will need to request space developer access every day in order to gain access to production.
See the [AKS cheatsheet](/docs/infra/aks-cheatsheet.md) to learn how to do this, and for other helpful tips.

### Azure CIP

You will need a CIP account in order to raise a PIM (Privileged Identity Management) request to change environment variables or access nightly database backups. Steps on how to register for a CIP account and raise a PIM request
can be found in the [DfE Technical Guidance](https://technical-guidance.education.gov.uk/infrastructure/hosting/azure-cip/).

## Access to QA, Sandbox and Production

- Navigate to the Support Sign in page: [QA](https://qa.apply-for-teacher-training.service.gov.uk/support/sign-in), [Staging](https://staging.apply-for-teacher-training.service.gov.uk/support/sign-in) and [production](https://www.apply-for-teacher-training.service.gov.uk/support/sign-in)
- If you already have a DfE Sign-in account, log in. If you do not click, `Create account` and follow the instructions
- Once you have successfully logged in, you should see a page stating your DfE Sign-in `UUID`
- Ask a colleague who has support access for the environment you are trying to access to go to the [Add support user page](https://www.apply-for-teacher-training.service.gov.uk/support/users/support/new) and add your email address and your `UUID` (from the last step).

Note: You can also navigate to the Add Support User page by logging into support and clicking `Settings`, `Support users` and `Add support user`

# Additional reading

Have a read through:
- [AKS developer onboarding](https://github.com/DFE-Digital/teacher-services-cloud/blob/main/documentation/developer-onboarding.md)
- [Teacher Services technical documentation](https://tech-docs.teacherservices.cloud/)
- [DfE Technical Guidance](https://technical-guidance.education.gov.uk/).

# Developer Slack Channels

These are a small number of recommended Slack channels for new developers to join

- Join `#apply-dev-notifications` for GitHub notifications from the [Apply teacher training](https://github.com/DFE-Digital/apply-for-teacher-training) and [Find/Publish for teacher training](https://github.com/DFE-Digital/publish-teacher-training) codebases

- `#civil_servant_devs` is a channel for civil servant developers. Join if you would like to be part of ongoing developer discussion, meet ups and technical talks.
This is a private channel, so ask a permanent developer within Teacher Services to invite you.

- `#developers` is a generic channel for anything technical related. It's for developers across DfE, not just in Teaching Workforce Directorate.

- `#twd_developers` is a channel for discussion between developers within the Teaching Workforce Directorate. Also join if you want to take part in developer meet ups
on Wednesdays at 15:00, every fortnight

- `#twd_find_and_apply_tech` is a channel for all technical discussion relating to the [Apply postgraduate teacher training](https://github.com/DFE-Digital/apply-for-teacher-training) and [Find/Publish for teacher training](https://github.com/DFE-Digital/publish-teacher-training) codebases

- For all Teacher services infrastructure related topics, join `#teacher-services-infra`
