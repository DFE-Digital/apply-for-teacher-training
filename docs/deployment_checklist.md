# Deploying Apply - Post-deployment checks

After deploying a new version of the service we have a short list of
tests to run through. The aim is to detect any obvious issues that have
been caused by the new release.

This checklist is meant as a supplement to the full [deployment guide](deployment.md)
where you will find detailed instructions about how to deploy.

It may be appropriate carry out additional checks specific to the
changes included in a deployment.

We aim to work in pairs on deployments so that one developer runs the
deployment itself and a second developer runs through this checklist.

## 1. Production checks

When the production deployment has finished ask another developer to go
through the following checks:

1. Notify the rest of the team via Slack that production is deployed.
2. Check
   [Sentry](https://sentry.io/organizations/dfe-bat/issues/?project=1765973)
   for runtime errors. These should also be shared in Slack in the
   #twd_apply_tech channel.
3. Create a new account on the system with a real email address and
   check that you receive an email with the magic link and can use it to
   log in. Use your DfE digital email address so that we can distinguish
   test users.  If needed you can suffix your name with `+n` to create a
   unique email address.
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
6. Check [Kibana](https://kibana.logit.io/app/kibana#/discover?_g=(refreshInterval:(pause:!t,value:0),time:(from:now-10m,to:now))&_a=(columns:!(status,hosting_environment),index:'8ac115c0-aac1-11e8-88ea-0383c11b333a',interval:auto,query:(language:kuery,query:''),sort:!('@timestamp',desc))) for errors in the log.
7. Move any cards in the Ready to Deploy columns of the Candidate and
   Provendor Trello boards to Done.
