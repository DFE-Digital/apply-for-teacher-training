## Context

<!-- Why are you making this change? What might surprise someone about it? -->

## Changes proposed in this pull request

<!-- If there are UI changes, please include Before and After screenshots. -->

## Guidance to review

<!-- How could someone else check this work? Which parts do you want more feedback on? -->

## Link to Trello card

<!-- http://trello.com/123-example-card -->

## Things to check

- [ ] This code does not rely on migrations in the same Pull Request
- [ ] If this code includes a migration adding or changing columns, it also backfills existing records for consistency
- [ ] API release notes have been updated if necessary
- [ ] This code does not rely on the addition/removal of Azure config environment variables in the same Pull Request
- [ ] New environment variables have been [added to the Azure config](https://github.com/DFE-Digital/apply-for-teacher-training/blob/master/docs/environment-variables.md#azure-hosting-devops-pipeline)
