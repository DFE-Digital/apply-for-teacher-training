# Environment Variables

Environment variables have to be defined in several places depending upon where they are required, some are common to both local development and the deployment application, while others are specific to the environments they relate, all of which are described below

Some environment variables like `ZENDESK_MESSAGING_KEY_CI` or `SLACK_WEBHOOK ` are defined in github secrets, at the repo level. To change this you need admin access to the repo.

## Dockerfile

If an environment variable is required during the Docker image build, like for example in the Rails asset compilation process, these should be defined in the Dockerfile in the following format.

`ENV VARIABLE_NAME=Value`

When defining variables in the Dockerfile use dummy values for security reasons since they will be committed to Git and they will ultimately be overriden by docker-compose when you launch a container using the image.

## Local Development

If an environment variable is required for use in the local development environment it should be declared in the .env file in the following format

`VARIABLE_NAME=Value`

The [.env.example](/.env.example) file contains the essential environment variables that must exist for local development builds to succeed.

## Docker Compose

For docker compose to make the necessary environment variables available in the container at run time they must be declared in the relevant docker-compose file.

* [docker-compose.yml](/docker-compose.yml) - Variables that are required for local dev should be defined the *environment* section in this file. This will in general only be for the database.

## Deploy Pipeline

Runtime environment variables and app secrets are stored in Azure KeyVault and the github actions workflow reads this secrets and configures them as environment variables during the deployment. All required app secrets and environment variables are stored as one YAML file inside Azure KeyVault and each key in the file is set as individual environment variable as part of the deployment.
Run the below commands from the root of the repository to view the current values stored in Key Vault.
You'll also need to be logged into your azure account using the [az cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).

Command                          | Description                                   |
---------------------------------| --------------------------------------------- |
make qa view-app-secrets         | View app secrets for `qa` environment         |
make staging view-app-secrets    | View app secrets for `staging` environment    |
make sandbox view-app-secrets    | View app secrets for `sandbox` environment    |
make production view-app-secrets | View app secrets for `production` environment |

**Please note that you'll need PIM access on the corresponding Azure subscription to view/edit app secrets in staging, sandbox and production environments.**

Command                          | Description                                   |
---------------------------------| --------------------------------------------- |
make qa edit-app-secrets         | Edit app secrets for `qa` environment         |
make staging edit-app-secrets    | Edit app secrets for `staging` environment    |
make sandbox edit-app-secrets    | Edit app secrets for `sandbox` environment    |
make production edit-app-secrets | Edit app secrets for `production` environment |
