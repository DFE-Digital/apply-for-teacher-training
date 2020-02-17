# Deploying Apply - Post-deployment checks

After deploying a new version of the service we have a short list of
tests to run through. The aim is to detect any obvious issues that have
been caused by the new release.

This checklist is meant as a supplement to the full [deployment guide](deployment.md)
where you will find detailed instructions about how to deploy.

It may be appropriate to carry out additional checks specific to the
changes included in a deployment.

We aim to work in pairs on deployments so that one developer runs the
deployment itself and a second developer runs through this checklist.

## 1. Staging checks

When the staging deployment has finished and before the production
deployment begins ask another developer to go through the following
checks:

1. Notify the rest of the team via Slack that staging is deployed and
   that final pre-production checks can be made.
2. Check the #twd_apply_tech channel in Slack for runtime errors from
   Sentry.
3. Create a new account on
   [staging](https://staging.apply-for-teacher-training.education.gov.uk/candidate)
   with a real email address and check that you receive an email with
   the magic link and can use it to log in. Use your DfE digital email
   address so that we can distinguish test users.  If needed you can
   suffix your name with `+n` to create a unique email address.
4. Check the Azure Dashboard for the staging
   [s106t01-apply](https://portal.azure.com/#@9c7d9dd3-840c-4b3f-818e-552865082e16/dashboard/private/6fef53c1-fbe3-4bd3-aa3d-8575eebb2424) resource
   group. Make sure that each of the following resources are running -
   this should be clear from the memory percentage and memory usage
   graphs, zero memory usage is a red flag.
     - Application Service (Web server) - `106t01-apply-asp`
     - PostgreSQL - `106t01-apply-psql`
     - Redis - `106t01-apply-redis`
     - Clock background process - `106t01-apply-ci-clk`
     - Sidekiq background process - `106t01-apply-ci-wkr`
5. Check the [Sidekiq management
   interface](https://staging.apply-for-teacher-training.education.gov.uk/support/sidekiq)
   for any signs that jobs are failing or that the length of the job
   queue is increasing.

## 2. Production checks

When the production deployment has finished ask another developer to go
through the following checks:

1. Notify the rest of the team via Slack that production is deployed and
   that final checks are being made.
2. Check the #twd_apply_tech channel in Slack for runtime errors from
   Sentry.
3. Create a new account on
   [production](https://www.apply-for-teacher-training.education.gov.uk/candidate)
   with a real email address and check that you receive an email with
   the magic link and can use it to log in. Use your DfE digital email
   address so that we can distinguish test users. If you already have an
   account for your DfE email address it's sufficient to log out and
   request a new magic link.
4. Check the Azure Dashboard for the production [s106p01-apply](https://portal.azure.com/#@9c7d9dd3-840c-4b3f-818e-552865082e16/dashboard/arm/subscriptions/67722207-6a10-4c7d-b4bc-c72caa76ef12/resourcegroups/s106p01-apply/providers/microsoft.portal/dashboards/s106p01-apply-dashboard) resource
   group. Make sure that each of the following resources are running -
   this should be clear from the memory percentage and memory usage
   graphs, zero memory usage is a red flag.
     - Application Service (Web server) - `106p01-apply-asp`
     - PostgreSQL - `106p01-apply-psql`
     - Redis - `106p01-apply-redis`
     - Clock background process - `106p01-apply-ci-clk`
     - Sidekiq background process - `106p01-apply-ci-wkr`
5. Check the [Sidekiq management
   interface](https://www.apply-for-teacher-training.education.gov.uk/support/sidekiq)
   for any signs that jobs are failing or that the length of the job
   queue is increasing.
