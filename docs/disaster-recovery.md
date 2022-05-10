# Disaster recovery

This documentation covers one scenario:

- [Data loss](#data-loss)

In case of any of the above disaster scenario, please do the following:

### Freeze pipeline

Alert all developers that no one should merge to main branch.

### Local Dependencies

You will need the [az](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) and [cf](https://docs.cloudfoundry.org/cf-cli/install-go-cli.html) CLIs installed as well as [jq](https://stedolan.github.io/jq/download/), [make](https://www.gnu.org/software/make/) and either [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) or [tfenv](https://github.com/tfutils/tfenv#installation).

### Maintenance mode

In the instance of data loss it will probably be desirable to enable [Maintenance mode](maintenance-mode.md) to ensure that the database is only read from and written to when it is back in it's expected state.

### Set up a virtual meeting

Set up virtual meeting via Zoom, Slack, Teams or Google Hangout, inviting all the relevant technical stakeholders. Regularly provide updates on
the #twd_publish Slack channel to keep product owners abreast of developments.

### Internet Connection

Ensure whoever is executing the process has a reliable and reasonably fast Internet connection.

## Loss of database instance

In case the database instance is lost, the objectives are:

- Recreate the lost postgres database instance
- Restore data from nightly backup stored in Azure.  The point-in-time and snapshot backups created by the PaaS Postgres service will not be available if it's been deleted.

### Recreate the lost postgres database instance

Please note, this process should take about 25 mins* to complete. In case the database service is deleted or in an inconsistent state we must recreate it and repopulate it.
First make sure it is fully gone by running

```
cf services | grep apply-postgres
# check output for lost or corrupted instance
cf delete-service <instance-name>
```
Then recreate the lost postgres database instance using the following make recipes `deploy-plan` and `deploy`.  To see the proposed changes:

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

You will need to be logged into GovUK PaaS and Azure using the `az` and `cf` CLIs.  You will need to raise a [PIM](https://docs.microsoft.com/en-us/azure/active-directory/privileged-identity-management/pim-resource-roles-activate-your-roles) request to elevate your credentials for a production restore.  A collegue will need to approve this for you.

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
