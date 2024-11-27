## Context

<!-- Why are you making this change? What might surprise someone about it? -->

## Changes proposed in this pull request

<!-- If there are UI changes, please include Before and After screenshots. -->

## Guidance to review

<!-- How could someone else check this work? Which parts do you want more feedback on? -->

## Things to check

- [ ] If the code removes any existing feature flags, a data migration has also been added to delete the entry from the database
- [ ] This code does not rely on migrations in the same Pull Request
- [ ] If this code includes a migration adding or changing columns, it also backfills existing records for consistency
- [ ] If this code adds a column to the DB, decide whether it needs to be in analytics yml file or analytics blocklist
- [ ] If this code adds a column that may include PII, the sanitise.sql script and 0025-protecting-personal-data-in-production-dump.md ADR have been updated.
- [ ] API release notes have been updated if necessary
- [ ] If it adds a significant user-facing change, is it documented in the [CHANGELOG](CHANGELOG.md)?
- [ ] Required environment variables have been updated [added to the Azure KeyVault](/docs/environment-variables.md#deploy-pipeline)
- [ ] Inform data insights team due to database changes
- [ ] Make sure all information from the Trello card is in here
- [ ] Rebased main
- [ ] Cleaned commit history
- [ ] Tested by running locally
- [ ] Add PR link to Trello card
