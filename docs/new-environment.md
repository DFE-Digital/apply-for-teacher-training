# Setting up new deployment environments

New deployment environments are configured by Azure specialists via the Azure YAML and JSON files.

Once a fresh environment is deployed, it is necessary to enable feature flags
and perhaps grant access to support and provider users.

To do this it's necessary to have a Support user set up, but support users are
created via the support UI, which is only accessible to Support users!

It is possible to grant access directly by updating the database of the environment
in question.

1. Connect to the database following the [instructions for connecting to a production database]('/docs/connecting-to-databases.md')
2. Issue the following query, which writes your email address (EMAIL) and DfE Sign-in uid (UID) into the support_users table.

```
INSERT INTO support_users (email_address, dfe_sign_in_uid, created_at, updated_at) VALUES ('EMAIL', 'UID', current_timestamp, current_timestamp);
```
