## Context

<!-- Why are you making this change? What might surprise someone about it? -->

## Changes proposed in this pull request

<!-- If there are UI changes, please include Before and After screenshots. -->

## Guidance to review

<!-- How could someone else check this work? Which parts do you want more feedback on? -->


## Things to check

- [ ] If the code removes any existing feature flags, a data migration has also been added to delete the entry from the database
- [ ] API release notes have been updated if necessary
- [ ] If it adds a significant user-facing change, is it documented in the [CHANGELOG](CHANGELOG.md)?
- [ ] Attach the PR to the Trello card
- [ ] This code adds a column or table to the database
  - [ ] This code does not rely on migrations in the same Pull Request
  - [ ] decide whether it needs to be in analytics yml file or analytics blocklist
  - [ ] data insights team has been informed of the change and have updated the pipeline
  - [ ] the sanitise.sql script and 0025-protecting-personal-data-in-production-dump.md ADR have been updated
  - [ ] does the code safely backfill existing records for consistency
