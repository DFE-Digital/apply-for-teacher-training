# Developer On-boarding

## Purpose

This document describes the on-boardng steps for new Developers when they join the team.

## You can request access to the following by asking in the #digital-tools-support slack channel:

- [DfE-Digital](https://github.com/DFE-Digital) GitHub group access. This will give you access to all repos. Ours are: [Find](https://github.com/DFE-Digital/find-teacher-training) and [Apply](https://github.com/DFE-Digital/apply-for-teacher-training)
- [Logit access](https://dashboard.logit.io/a/eeeb8311-79d8-49ab-9410-9b6d76b26f72) (Stack: Becoming a teacher - PaaS)
- [Sentry access](https://sentry.io/auth/login/dfe-teacher-services/)

## PaaS/DevOps steps

### Get a PaaS account
You can get an account by requesting one in the `#digital-tools-support` Slack channel. Request an account with a SpaceDeveloper role for your @digital.education.gov.uk email address with access to the `dfe` organisation and `bat-prod`, `bat-staging` and `bat-qa` spaces.

### Install the CloudFoundary CLI
PaaS is built on CloudFoundary and we use the CloudFoundary CLI to interact with PaaS. You can install version 7 of the CLI [here](https://github.com/cloudfoundry/cli#downloads).

### Getting familiar with PaaS
See [PaaS cheatsheet](/docs/paas-cheatsheet.md).

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

Have a read through [Teacher Services technical documentation](https://teacher-services-tech-docs.london.cloudapps.digital/#teacher-services-technical-documentation) and [DfE Technical Guidance](https://technical-guidance.education.gov.uk/).
