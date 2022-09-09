# Disaster recovery

This documentation covers two scenarios:

- [Loss of database instance](#loss-of-database-instance)
- [Data loss](#data-loss)

In case of any of the above disaster scenario, please do the following:

## Pre-requisites
### Local Dependencies

You will need the following tools installed to successfully complete the process:
- [az](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [cf](https://docs.cloudfoundry.org/cf-cli/install-go-cli.html)
- [conduit](https://github.com/alphagov/paas-cf-conduit)
- pg_dump:
  - WSL/Linux: `sudo apt-get install postgresql-client`
  - MacOS: `brew install postgresql@11` then ensure pg_dump is available in the PATH run `echo 'export PATH="/opt/homebrew/opt/postgresql@11/bin:$PATH"' >> ~/.zshrc` and `/opt/homebrew/opt/postgresql@11/bin/postgres -D /opt/homebrew/var/postgresql@11` if you don't want/need it as a background service.
- [jq](https://stedolan.github.io/jq/download/)
- [make](https://www.gnu.org/software/make/)
- either [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) or [tfenv](https://github.com/tfutils/tfenv#installation)
  - the correct version of Terraform installed (`tfenv install 1.2.3`)

### Accounts

CIP Account
- Ensure access to the CIP Azure Platform. Raise a Service Now request to obtain access if required
- Ensure the CIP account is added to the s121 AAD groups
- Check the account by logging in to https://portal.azure.com
  - If this is the first time logging in multi-factor either will need setting up
  - Switch the directory to DFE Platform Identity
  - When performing the restore against production raise a PIM request to elevate your privileges
- Confirm you can use the Azure CLI from the command-line by logging un using `az login`

GOV.UK PaaS Passcode
- Get a passcode here: https://login.london.cloud.service.gov.uk/passcode

### Freeze pipeline

Alert all developers that no one should merge to main branch.

### Enable maintenance mode

In the instance of data loss it will probably be desirable to enable [Maintenance mode](maintenance-mode.md) to ensure that the database is only read from and written to when it is back in it's expected state.

### Set up a virtual meeting

Set up a virtual meeting via Zoom, Slack, Teams or Google Meet, inviting all the relevant technical stakeholders. Regularly provide updates on
the #twd_apply Slack channel to keep product owners abreast of developments.

### Internet Connection

Ensure whoever is executing the process has a reliable and reasonably fast Internet connection.

## Loss of database instance

In case the database instance is lost, the objectives are:

- Recreate the lost postgres database instance
- Restore data from nightly backup stored in Azure. The point-in-time and snapshot backups created by the PaaS Postgres service will not be available if it's been deleted.

### Recreate the lost postgres database instance

Please note, this process should take about 25 mins* to complete. In case the database service is deleted or in an inconsistent state we must recreate it and repopulate it. When testing the process a manual deletion of the database service requires the associated keys to be deleted first. Run `cf service-keys apply-postgres-qa` to list the service keys and then `cf delete-service-key apply-postgres-qa <service-key-name>` for each key to delete it.

Ensure the service is fully removed by running.

```
cf services | grep apply-postgres
# check output for lost or corrupted instance
cf delete-service <instance-name>
```
Then recreate the lost postgres database instance using the following make recipes `deploy-plan` to test the plan and `deploy` to make the changes.  To see the proposed changes:

```
TAG=$(cf app apply-<env> | awk -F : '$1 == "docker image" {print $3}')
make <env> deploy-plan PASSCODE=<my-passcode> IMAGE_TAG=${TAG} [CONFIRM_PRODUCTION=YES]
```
To apply proposed changes i.e. create new database instance:
```
TAG=$(cf app apply-<env> | awk -F : '$1 == "docker image" {print $3}')
make <env> deploy PASSCODE=<my-passcode> IMAGE_TAG=${TAG} [CONFIRM_PRODUCTION=YES]
```
This will create a new postgres database instance as described in the terraform configuration file.

\* based on ~20 minutes to recreate postgres instance and ~5 min restore time when testing process in QA

### Restore Data From Nightly Backup

You will need to be logged into GovUK PaaS and Azure using the `az` and `cf` CLIs. You will need to raise a [PIM](https://docs.microsoft.com/en-us/azure/active-directory/privileged-identity-management/pim-resource-roles-activate-your-roles) request to elevate your credentials for a production restore.  A collegue will need to approve this for you.

Once the lost database instance has been recreated, the last nightly backup will need to be restored. To achieve this, use the following makefile recipe: `restore-data-from-nightly-backup`. The following will need to be set: `CONFIRM_PRODUCTION=YES`,  `CONFIRM_RESTORE=YES` and `BACKUP_DATE="yyyy-mm-dd"`.

The make recipe `restore-data-from-nightly-backup` executes 2 scripts, these should be committed with the execute permission (755) set but these may have been inadvertently altered.  If you get a permissions error executing them run `chmod +x <path/to/script>`.

```
# space is the name of the environment in GOV.UK PaaS, eg 'bat-prod'
# env is the target environment in the make file e.g. 'production'
az login
cf login -o dfe -s <space> -u my.name@digital.education.gov.uk
make <env> restore-data-from-nightly-backup BACKUP_DATE="yyyy-mm-dd" CONFIRM_PRODUCTION=YES CONFIRM_RESTORE=YES
```

This will download the latest daily backup from Azure Storage and then populate the new database with data.  If more than one backup has been created on the date specified the script will select the most recent from that date.

During the restore process a number of errors are expected because the permission level being used is not high enough to perform actions on certain database objects. These are listed below:
```
ERROR:  must be owner of event trigger reassign_owned (or make_readable, forbid_ddl_reader)
ERROR:  must be owner of function public.reassign_owned (or public.make_readable_generic, public.make_readable, public.forbid_ddl_reader)
ERROR:  must be owner of extension uuid-ossp (or postgis, pg_stat_statements, pg_buffercache, citext, btree_gist, btree_gin)
ERROR:  function "forbid_ddl_reader" already exists with same argument types (or "make_readable", "make_readable_generic", "reassign_owned")
ERROR:  permission denied for table spatial_ref_sys
ERROR:  permission denied to create event trigger "forbid_ddl_reader" (or "make_readable", "reassign_owned")
```

### Disable maintenance mode

Before disabling maintenance mode, check that the app is up using the internal URL `apply-qa.london.cloudapps.digital` visibile with `cf apps | grep apply-qa`. If the site is up then [Maintenance mode](maintenance-mode.md) can be disabled.

## Data Loss

In the case of a data loss, we need to recover the data as soon as possible in order to resume normal service. Declare a major incident and document the incident timelines as you go along.

The application's database is a postgres instance, which resides on PaaS. This provides a point-in-time backup with the resolution of 1 second, available between 5min and 7days. We can use terraform to create a new database instance and use a point-in-time backup from the corrupted instance to restore the data.  This will be done in a single terraform apply operation.

### Make note of database failure time

Make note of the time the database failure occurred, and then use this to calculate when the integrity of the data in the database was still viable. For instance, if data loss or corruption happened at 1200hrs, use this to work out what snapshot time is best for the product (consult with the PM if you are unsure what would be best from the product perspective). This would determine the value of `SNAPSHOT_TIME` env.

Important: You should convert the time to UTC before actually using it. When you record the time, note what timezone you are using. Especially during BST (British Summer Time).

### Get affected postgres database ID

Use the makefile's get-postgres-instance-guid to get the database guid, use the following command:

```
make <env> get-postgres-instance-guid [CONFIRM_PRODUCTION=true]
```
env is the target environment e.g. production


### Rename postgres database instance service

Rename the affected database instance so a new database can be recreated with the production name. To achieve this, run the following make command

```
make <env> rename-postgres-service NEW_NAME_SUFFIX=backup passcode=xxxx [CONFIRM_PRODUCTION=true]
```
this renames the database by appending the suffix (e.g. "-backup") to the database name, env is the target environment e.g. production, obtain a passcode from [GOV.UK PaaS one-time passcode](https://login.london.cloud.service.gov.uk/passcode)

### Remove affected postgres database instance from terraform state file

In order for terraform to be able to create a new database instance, the existing database reference needs to be removed from the state file. This is to ensure it is no longer managed by terraform, otherwise, terraform would revert our changes. To achieve this, use the makefile target -

```
az login # authenticate to Azure because statefile is in an Azure Storage Container
make <env> remove-postgres-tf-state PASSCODE=xxxx [CONFIRM_PRODUCTION=true]
```
env is the target environment e.g. production

### Restore postgres database instance

The following variables need to be set: DB_INSTANCE_GUID (the output of the 'Get affected postgres instance guid' step, SNAPSHOT_TIME ("2021-09-14 16:00:00" IMPORTANT - this is UTC time!), passcode (a passcode from [GOV.UK PaaS one-time passcode](https://login.london.cloud.service.gov.uk/passcode)), CONFIRM_PRODUCTION (true) and tag (the docker tag for the application image).

The following commands combine the makefile recipes above to initiate the restore process by using the approriate variable values:

```
# space is the name of the environment in GOV.UK PaaS, eg 'bat-prod'
# env is the target environment in the make file e.g. 'production'
az login
cf login -o dfe -s <space> -u my.name@digital.education.gov.uk
PASSCODE=xxxx # obtain from https://login.london.cloud.service.gov.uk/passcode
DB_INSTANCE_GUID=$(make <env> get-postgres-instance-guid)
TAG=$(make <env> get-image-tag)
make <env> rename-postgres-service NEW_NAME_SUFFIX=backup PASSCODE=${PASSCODE} CONFIRM_RENAME=y
make <env> remove-postgres-tf-state PASSCODE=${PASSCODE}
make <env> restore-postgres DB_INSTANCE_GUID=${DB_INSTANCE_GUID} SNAPSHOT_TIME="yyyy-mm-dd HH:MM:ss" PASSCODE=${PASSCODE} IMAGE_TAG=${TAG}
```

You will be prompted to review the terraform plan. Check for the following:
- the `cloudfoundry_app.docker_image` tags are **not** changing
- a new database instance is being created using a point-in-time database backup of corrupted database
- new service keys are created

The restore process should take ~25 min. Terraform should write logs to the console with progress, the bulk of the time will be spent recreating the postgres instance.

### PaaS documentation

Gov UK PaaS Documentation on Point-in-time database recovery can be found [here](https://docs.cloud.service.gov.uk/deploying_services/postgresql/#restoring-a-postgresql-service-from-a-point-in-time)

### Tidy up

Once the database has been successfully restored, the corrupted database instance should be deleted.

```
cf delete-service apply-postgres-<env>-backup -f
```
