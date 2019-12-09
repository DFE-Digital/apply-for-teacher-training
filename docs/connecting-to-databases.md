# Apply for Postgraduate Teacher Training - Production database access

## Purpose

This document describes how to connect to databases in Microsoft Azure, including production.

## Prerequisites

To get the database password for a production environment you will need [elevated PIM permissions](/docs/pim-guide.md).
For development and test environments no elevation is necessary.

## Instructions

### Get a connection string

1. Figure out the Azure identifier for the database you wish to connect to. This is a string
on the model of `s106{ENV}-apply-psql` where ENV is a value like `d01` for QA or `p01` for prod.
1. Visit that resource’s page in Azure by searching for it.
1. When you get there, click on "Connection security" on the left hand side and add your IP to the whitelist
by clicking "Add client IP", labelling your IP with a sensible value, and clicking "Save". A notification
will pop up after a few seconds to show the operation is complete.
1. Get the `psql` connection string — the CLI command which will open a console on the
database instance — by clicking "Connection strings" on the left. This
string will have two placeholder values: `database_name` and `your_password`.

### Populate the connection string credentials

1. Obtain the database_name and database_password values by visiting the app service
corresponding to the database. To find out the identifier for the app service substitute `psql` for `as` in the
resource identifier. e.g. for production (database `s106p01-apply-psql`) you need to visit `s106p01-apply-as`.
Be careful not to visit "Application Insights" instead of "App Service" — they share an identifier.
1. From the app service page, visit "Configuration" to view the environment variables in that app service.
1. Click on the `DB_DATABASE` and `DB_PASSWORD` keys to obtain the values for the placeholders in the connection string.

### Use and cleanup

Replace the placeholders in the connection string and run it to connect to the database from your local machine.

Once you're finished, visit the database (`*-psql`) in Azure again and remove your client IP from the whitelist.

### Troubleshooting

If you see the following message on trying to connect, you may have a version conflict
between your local copy of `psql` and the `postgres` version running in Azure (9.6 at time of writing).

```
psql: error: could not connect to server: server closed the connection unexpectedly
	This probably means the server terminated abnormally
	before or while processing the request.
```

Check your `psql` version using `psql --version`.
