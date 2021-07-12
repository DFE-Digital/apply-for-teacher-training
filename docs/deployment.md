# How to: deploy Apply

The apply build and release process is split into two separate Azure DevOps pipelines.

- [apply-for-teacher-training](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_build?definitionId=49&_a=summary): This is the main development CI pipeline which will automatically trigger a build from a commit to any branch within the Apply GitHub code repository. When commits are made to the main branch, this pipeline will also deploy the application to the QA infrastructure environment in Azure automatically.

- [apply-for-teacher-training-releases](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_build?definitionId=325&_a=summary): This is the main release pipeline that is used to deploy to all other Azure environments except QA. Releases are triggered manually and the target environments can be chosen prior to deployment.

All members of the Apply development team are able to deploy into any of the environments.

To speed up the release pipeline, logic has been introduced into the pipeline code to only run the full ARM template deployment only if the following conditions are met.
- Any of the pipeline variable groups associated with the deployment have changed since the last successful deployment
- Any of the following files have changed in the commit associated with the build:
  - azure/pipelines/build.yml
  - azure/pipelines/release.yml
  - azure/pipelines/templates/deploy.yml
  - azure/template.json
  - azure/containers.json
If none of the above conditions are met the pipeline will simply load the new image into the container staging slot ready for swapping.

## 1. Check what you're deploying

Go to [the Apply Ops Dashboard](https://apply-ops-dashboard.azurewebsites.net) and find the commit you want to deploy
and check the diff on GitHub to see if there's anything risky.

You also have to make sure that you're deploying only work that is safe to deploy. It should be either behind a feature flag or product reviewed.

## 2. Deploy to staging

### From the Ops Dashboard
Click on the `Deploy` button next to the commit SHA under Staging section in the dashboard.

You might be prompted to login to Azure AD and grant permissions for the deployment. You won't be prompted to login to Azure again if an active session exists.

Once the deployment begins, this will automatically post the list of PRs being deployed to the `#twd_apply` slack channel.

### Manually
Summarise what you're deploying and tell the team in Slack on the `#twd_apply` channel. Use `:ship_it_parrot:` as required.
1. Load the [apply-for-teacher-training-releases](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_build?definitionId=325&_a=summary) page in Azure DevOps.
1. Click the blue "Run pipeline" button (sometimes it says "Queue") at the top right of the page which will open the run pipeline menu.
1. Ensure the branch is set to "main".
1. Specify the commit
1. Under the Variables section, make sure only `deploy_staging` is set to true (this should be the default)
1. Click the Run button to start the deployment.

## 3. Check if staging is deployed successfully

Check the `#twd_apply_tech` channel in Slack for runtime errors from
Sentry or the smoke tests.

## 4. Deploy to production and sandbox

### From the Ops Dashboard
Click on the `Deploy` button next to the commit SHA under the Production section of the dashboard.

### Manually
1. Load the [apply-for-teacher-training-releases](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_build?definitionId=325&_a=summary) page in Azure DevOps.
1. Click the blue "Run pipeline" button (sometimes it says "Queue") at the top right of the page which will open the run pipeline menu.
1. Ensure the branch is set to "main".
1. Specify the commit again - **do not forget this**
1. Under the Variables section set `deploy_staging` to `false` and `deploy_production` and `deploy_sandbox` to `true`.
1. Click the Run button to start the deployment

## 5. Check if production and sandbox are deployed successfully

Check the `#twd_apply_tech` channel in Slack for runtime errors from
Sentry or the smoke tests.

## 6. Move deploy cards to done

Tell your team mates that their work has gone out. They should now move over their deployed cards in "Ready to deploy" to "Product review & launch 🚀" on the [Candidate board](https://trello.com/b/aRIgjf0y/candidate-team-board) and/or [ProVendor board](https://trello.com/b/5IiPW0Ok/team-board-apply).

## Rolling back

_Note that this advice does not apply if you are deploying changes to the Azure
templates. If you deploy breaking Azure template changes, the only way to roll
back is to run a full redeploy._

Because we operate blue/green deployments, the previous version of the app is
always available in the staging slot. To roll back to it, use the [swap-slots pipeline](swap-slots-pipeline.md).
Once the pipeline is complete, the old version of the app will be running at the live URL.

To roll back to an earlier version, see the [Manual Deployment guide](manual-deployment.md).
