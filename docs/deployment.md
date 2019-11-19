# Deploying Apply - Step by step  

All members of the Apply development team are able to deploy into any of the environments.

## 1. Check what you're deploying

Go to [the lists of commits on the repo](https://github.com/DFE-Digital/apply-for-postgraduate-teacher-training/commits/master) and find the commit you want to deploy. It needs to have been deployed to QA - you can normally see this by checking if it has a green checkmark.

![](/docs/latest-commits.png)

Find the latest commit on production and compare it with the commit you want to deploy.

For example:

https://github.com/DFE-Digital/apply-for-postgraduate-teacher-training/compare/7d8db2daad0c3ae67574eaf0efcb9a4e87dca49a...b785e087391d7d5e6e91c1a00a0a4b1b625ebf48

You also have to make sure that you're deploying only work that has been product reviewed. The "Product Review" column on the [Candidate board](https://trello.com/b/aRIgjf0y/candidate-team-board) and [ProVendor board](https://trello.com/b/5IiPW0Ok/team-board-apply) should be empty.

👷‍♀️ WIP: we're working to making the compare URL easier to generate

## 2. Tell the team ![](https://cultofthepartyparrot.com/parrots/shipitparrot.gif)

Summarise what you're deploying and tell the team in Slack on the `#twd_apply` channel. Use `:ship_it_parrot:` as required.

## 3. Deploy to staging

1. Load the [apply-for-teacher-training-releases](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_build?definitionId=325&_a=summary) page in Azure DevOps.
1. Click the blue "Run pipeline" button at the top right of the page which will open the run pipeline menu.
1. Ensure the branch is set to "master".
1. Specify the commit
1. Under the Variables section, make sure only `deploy_staging` is set to true
1. Click the Run button to start the deployment.

## 4. Test on staging

Do whatever it takes to test what you've just deployed. Be sure to keep an eye on [Sentry](https://sentry.io/organizations/dfe-bat/issues/?project=1765973) for any incoming issues.

## 5. Deploy to production, sandbox and pentest

1. Load the [apply-for-teacher-training-releases](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_build?definitionId=325&_a=summary) page in Azure DevOps.
1. Click the blue "Run pipeline" button at the top right of the page which will open the run pipeline menu.
1. Ensure the branch is set to "master".
1. Specify the commit again
1. Under the Variables section set `deploy_staging` to `false` and `deploy_pentest`, `deploy_production` and `deploy_sandbox` to `true`.
1. Click the Run button to start the deployment

## 6. Test on production

Wait until the deploy finishes and, if necessary, test on production.

## 7. Move deploy cards to done

Tell your team mates that their work has gone out, and move over all of the cards in "Ready to deploy" to done on the [Candidate board](https://trello.com/b/aRIgjf0y/candidate-team-board) and [ProVendor board](https://trello.com/b/5IiPW0Ok/team-board-apply).
