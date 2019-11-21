# Deploying Apply - Step by step  

All members of the Apply development team are able to deploy into any of the environments.

## 1. Check what you're deploying

Go to [the Apply Ops Dashboard](https://apply-ops-dashboard.herokuapp.com/) and find the commit you want to deploy.

Make sure to check the diff on GitHub to see if there's anything risky.

You also have to make sure that you're deploying only work that has been product reviewed. The "Product Review" column on the [Candidate board](https://trello.com/b/aRIgjf0y/candidate-team-board) and [ProVendor board](https://trello.com/b/5IiPW0Ok/team-board-apply) should be empty.

## 2. Tell the team ![](https://cultofthepartyparrot.com/parrots/shipitparrot.gif)

Summarise what you're deploying and tell the team in Slack on the `#twd_apply` channel. Use `:ship_it_parrot:` as required.

## 3. Deploy to staging

1. Load the [apply-for-teacher-training-releases](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_build?definitionId=325&_a=summary) page in Azure DevOps.
1. Click the blue "Run pipeline" button (sometimes it says "Queue") at the top right of the page which will open the run pipeline menu.
1. Ensure the branch is set to "master".
1. Specify the commit
1. Under the Variables section, make sure only `deploy_staging` is set to true (this should be the default)
1. Click the Run button to start the deployment.

## 4. Test on staging

Do whatever it takes to test what you've just deployed. Be sure to keep an eye on [Sentry](https://sentry.io/organizations/dfe-bat/issues/?project=1765973) for any incoming issues.

## 5. Deploy to production, sandbox and pentest

1. Load the [apply-for-teacher-training-releases](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_build?definitionId=325&_a=summary) page in Azure DevOps.
1. Click the blue "Run pipeline" button (sometimes it says "Queue") at the top right of the page which will open the run pipeline menu.
1. Ensure the branch is set to "master".
1. Specify the commit again - **don't forget this** 
1. Under the Variables section set `deploy_staging` to `false` and `deploy_pentest`, `deploy_production` and `deploy_sandbox` to `true`.
1. Click the Run button to start the deployment

## 6. Test on production

Wait until the deploy finishes and, if necessary, test on production.

## 7. Move deploy cards to done

Tell your team mates that their work has gone out, and move over all of the cards in "Ready to deploy" to done on the [Candidate board](https://trello.com/b/aRIgjf0y/candidate-team-board) and [ProVendor board](https://trello.com/b/5IiPW0Ok/team-board-apply).
