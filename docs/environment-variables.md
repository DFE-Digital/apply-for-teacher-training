# Environment Variables

Environment variables have to be defined in several places depending upon where they are required, some are common to both local development and the deployment application, while others are specific to the environments they relate, all of which are described below

## Dockerfile

If an environment variable is required during the Docker image build, like for example in the Rails asset compilation process, these should be defined in the Dockerfile in the following format.

`ENV VARIABLE_NAME=Value`

When defining variables in the Dockerfile use dummy values for security reasons since they will be committed to Git and they will ultimately be overriden by docker-compose when you launch a container using the image.

## Local Development

If an environment variable is required for use in the local development environment it should be declared in the .env file in the following format

`VARIABLE_NAME=Value`

The [.env.example](../.env.example) file contains the essential environment variables that must exist for local development builds to succeed.

## Docker Compose

For docker compose to make the necessary environment variables available in the container at run time they must be declared in the relevant docker-compose file.

* [docker-compose.yml](../docker-compose.yml) - Variables that are required for local dev should be defined the *environment* section in this file. This will in general only be for the database.

## Deploy Pipeline

Runtime environment variables and app secrets are stored in Azure KeyVault and the github actions workflow reads this secrets and configures them as environment variables during the deployment. All required app secrets and environment variables are stored as one YAML file inside Azure KeyVault and each key in the file is set as individual environment variable as part of the deployment.
Run the below commands from the root of the repository to view the current values stored in Key Vault.
You'll also need to be logged into your azure account using the [az cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).

Command                          | Description                                   | Azure Subscription
---------------------------------| --------------------------------------------- |---------------------
make qa view-app-secrets         | View app secrets for `qa` environment         | s121-findpostgraduateteachertraining-development
make staging view-app-secrets    | View app secrets for `staging` environment    | s121-findpostgraduateteachertraining-test
make sandbox view-app-secrets    | View app secrets for `sandbox` environment    | s121-findpostgraduateteachertraining-production
make production view-app-secrets | View app secrets for `production` environment | s121-findpostgraduateteachertraining-production

**Please note that you'll need PIM access on the corresponding Azure subscription to view/edit app secrets in staging, sandbox and production environments.**

Command                          | Description                                   | Azure Subscription
---------------------------------| --------------------------------------------- |---------------------
make qa edit-app-secrets         | Edit app secrets for `qa` environment         | s121-findpostgraduateteachertraining-development
make staging edit-app-secrets    | Edit app secrets for `staging` environment    | s121-findpostgraduateteachertraining-test
make sandbox edit-app-secrets    | Edit app secrets for `sandbox` environment    | s121-findpostgraduateteachertraining-production
make production edit-app-secrets | Edit app secrets for `production` environment | s121-findpostgraduateteachertraining-production

### View the current app environment variables

The `cf app <app-name>` command can be used to view/verify the current environment variables for the app.
Example: `cf app apply-qa` to view the environment variables for the apply web app.

App Name              | Space
----------------------|---------
apply-qa              | bat-qa
apply-clock-qa        | bat-qa
apply-worker-qa       | bat-qa
apply-staging         | bat-staging
apply-clock-staging   | bat-staging
apply-worker-staging  | bat-staging
apply-sandbox         | bat-prod
apply-clock-sandbox   | bat-prod
apply-worker-sandbox  | bat-prod
apply-prod            | bat-prod
apply-clock-prod      | bat-prod
apply-worker-prod     | bat-prod

### Ad-hoc environment variable changes
`cf set-env <app-name>` can be used to make changes to the environment variables without having to do a full deployment.
But please note that any change will be overridden during the next deployment.

```
cf set-env apply-qa <ENV_VAR_NAME> <VALUE> ## sets ENV_VAR_NAME=VALUE
cf restart apply-qa --strategy rolling ## restart app without causing downtime for the change to be reflected
```
