# How to: create and deploy a new environment in Azure

All the steps required to create and deploy to an Azure environment are written in the [Pipelines deploy template file](../azure/pipelines/templates/deploy.yml). This template is referenced inside the main Azure Pipelines configuration file and reused with appropriate parameters for the required environment.

## Configure Variable Groups in Azure DevOps
For deploying to a new environment, we need to configure the required variables in a variable group that will hold the values to be passed as parameters to the pipeline deployment steps.

Below are the existing variables groups used in the apply pipelines.
The groups with `APPLY - ENV` prefix hold environment specific values.
Variable Groups |
------------ |
APPLY - ENV - DevOps |
APPLY - ENV - Production |
APPLY - ENV - QA |
APPLY - ENV - Sandbox |
APPLY - ENV - Staging |
APPLY - Shared Variables |
Docker Shared Variables |

To create a new environment, clone an existing environment specific variable group and change the appropriate values.

## Create a new stage in the deployment pipeline for the new environment

There are two deployment stages defined in `build.yml`, `deploy_qa` and `deploy_devops` to deploy to QA and DevOps environment respectively. `deploy_qa` stage is run only if the build is triggered for the `main` branch and `deploy_devops` stage only if the build is triggered from a branch name defined in `devDeployBranchNameOverride` variable inside the `APPLY - ENV - DevOps` variable group.

To create or deploy to a new environment, create a new stage in the pipeline by cloning an existing stage and modifying the run conditions and variables.

Use [build.yml](../azure/pipelines/build.yml) for new dev/test environments and [release.yml](../azure/pipelines/release.yml) for environments in production.

Make sure to change the `subscriptionPrefix` and `subscriptionName` to reflect the correct Azure Subscription to be used for the new environment.  

The value used for `resourceEnvironmentName` should be used as the prefix for the host value defined inside the `authorisedHosts` variable in the variable group.  

`customAvailabilityMonitors` value should be changed to be used the same host as defined in `authorisedHosts`.

>Eg: If `resourceEnvironmentName` is `d02` and the azure subscription is `s106`, `authorisedHosts` value should be `s106d02-apply-as.azurewebsites.net,s106d02-apply-as-staging.azurewebsites.net`

`resourceEnvironmentName` should follow the below naming format as a policy.

Format | Environment |
------------ | ------------ |
dNN | Dev & QA |
tNN | Staging |
pNN | Production |

`NN` is a number with 2 digit places.

The first step defined in the deploy template is a script which determines if a full ARM deployment is required.
A full ARM deployment will be run when the pipeline is triggered for the first time after a new stage is configured.

Please note that a new deployment of redis usually takes about 25 minutes to complete and the resource might not be available for use (eg: referencing the connection string using `resourceId()`) in subsequent ARM steps even though you can see a redis instance has been provisioned, this causes the pipeline to fail when run for the first time. We also need to regenerate the primary and secondary access keys for redis from the Azure portal so that they do not contain any special characters except for `=` at the end and rerun the pipeline.

## Setting up feature flags for new environments

Once a fresh environment is deployed, it is necessary to enable feature flags and perhaps grant access to support and provider users.

To do this it's necessary to have a Support user set up, but support users are
created via the support UI, which is only accessible to Support users!

It is possible to grant access directly by updating the database of the environment
in question.

1. Connect to the database following the [instructions for connecting to a production database](connecting-to-databases.md)
2. Issue the following query, which writes your email address (EMAIL) and DfE Sign-in uid (UID) into the support_users table.

```SQL
INSERT INTO support_users (email_address, dfe_sign_in_uid, created_at, updated_at)
VALUES ('EMAIL', 'UID', current_timestamp, current_timestamp);
```

## Removing an environment

When there is no longer a need for a environment, please delete all the resources in the environment by deleting the resource group from the Azure portal. Also make sure to delete the corresponding variable group inside Azure DevOps and remove the stages from corresponding pipeline yml file.
