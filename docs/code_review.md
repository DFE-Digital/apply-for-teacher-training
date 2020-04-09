# Things to look out for in code review

### Does this PR add or change data?

- Is it backwards compatible? Does it backfill data?
- Might the data contain PII?  It might turn up in
  - the audit log
  - application logs
- Is it suitable for all the places it will be displayed? It could show up on
  - the candidate interface, pre- and/or post- application
  - the provider interface
  - the vendor API

- Should it be part of the test data generation scripts?

### Does it require database state to review?

If so, should it be part of the `setup_local_dev_data` rake task which we run locally and on Heroku review apps?

### Does it add any emails?

- Do they have previews?
- Do they need entries in the “What emails are sent?” documentation?

### Is it part of a sequence of PRs?

If this PR finishes off a feature, consider re-reviewing the other PRs that
went into to the feature before approving this one.
