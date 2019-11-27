# Apply for Postgraduate Teacher Training - Manual Deployment

## Purpose

This document describes the process of restoring the database from the Azure backups.

Azure retains Postgres database backups for up to 35 days depending upon the configuration used. The Apply production environment has the full 35 days backup, the other environments have the retention period reduced to seven days.

This document assumes that only the data in the database itself is at fault and the database server still exists.

## Prerequisites

To carry out a production database restore routine you will be required to have the following software installed:
- PostgreSQL 9.6.x client (specifically `pg_dump` and `pg_restore`)

## Instructions

**NOTE: Before following the steps below you will need to request an elevation of your rights to the 'contributor' role through PIM in the Azure Portal if working on an app hosted in the test or production subscriptions. Guidance on PIM can be found at the end of this document. PIM is not required in the development subscription.**

These instructions assume that you are working on the production environment, but they apply equally to the other environments by substitution of the resource names prefix for the chosen environment.

1. Launch the [Azure Portal](https://portal.azure.com).
1. Go to the "Resource groups" blade.
1. Select the `s106p01-apply` resource group.
1. Select the Azure Database for PostgreSQL server database named `s106p01-apply-psql` from the list of resources.
1. Click the "Restore" button in the ribbon at the top of the database resource page.
1. Select the point in time you wish to restore to and enter a name for the new database server, e.g. `s106p01-apply-psql-restored`. The naming prefix convention must be adhered to; CIP's policy enforcement will prevent the use of non-conforming names.
1. Click the OK button to start the restore process. This will take in the region of ten to fifteen minutes to completely restore the database to a new server, depending upon the size of the database.
1. While the restore is running, determine the public IP address of your local machine.
1. Return to the `s106p01-apply` resource group page and select the `s106p01-apply-psql` server from the resource list.
1. Select "Connection Security" from the Settings menu on the left.
1. Create a new rule to allow connections from your public IP. Ensure that the rule has a suitable name so that attributed to the user. Once the details have been entered, click Save.
1. Once the database restore process has finished, go back to the resource group listing and set up a connection rule in the same manner on the restored Postgres server, `s106p01-apply-psql-restored`.
1. On your local machine run the command `pg_dump -Fc -v -h s106p01-apply-psql-restored.postgres.database.azure.com -p 5432 -U applyadm512@s106p01-apply-psql-restored -W apply -f <output_filname>.dump` to dump the database to your local machine. The Azure postgres servers require SSL connections so you may need to specify the environment variable `PGSSLMODE=required` to establish a connection. The password can be found by examining the app service environment variables in the Azure portal.
1. Restore the database to the original instance using the command `pg_restore -v --no-owner -h s106p01-apply-psql.postgres.database.azure.com -p 5432 -U applyadm512@s106p01-apply-psql -W -d apply <input_filenme>.dump`
1. Verify that the database restore has been successful.
1. Return to the `s106p01-apply` resource group page and select checkbox alongside the restored database instance `s106p01-apply-psql-restored` and click the "Delete" button from the ribbon at the top of the resource group blade. In the popup menu that appears confirm the delete operation as directed.
1. Finally, select the `s106p01-apply-psql` from the resource list and go to "Connection Security" and remove the IP address you added earlier to ensure the server is fully secure again.


## PIM Rights Elevation

1. Launch the Azure portal at https://portal.azure.com.
1. Ensure you are using the "DfE Platform Identity" directory (see step 5 above if not).
1. In the search bar at the top of the portal type in "PIM" and select "Azure AD Privileged Identity Management" from the search results.
1. In the new blade that opens select "My roles" from the tasks section of the menu bar on the left.
1. Under the "Activate" section of the menu select "Azure Resources".
1. Choose the subscription you want to elevate your rights on and click "Activate". This will launch a new panel where you can specify duration and reason which must be completed before you can click Activate.
1. A request will be sent to the approving users, currently Tom/Riz and they will approve your request for elevated rights.
