# Pipeline Variables

The pipeline varianbles can be found in [Azure DevOps](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_library?itemType=VariableGroups)

Each environment has three tiers of pipelines variables, listed below and starting with the least specific first.
1. `Docker Shared Variables` - This group is common to all environments in Apply and also Find. It contains the login credentials from Dockerhub used during the build and deployment processes.
1. `APPLY - Shared Variables` - This group is used for all environment deployments in Apply only and covers credentials and configuration common to all of Apply's environment.
1. `APPLY - ENV - EnvironmentName` - These groups are named in correspondance with the envioronments to which they apply and contain credentials and configuration variables specific to those environments.

**NOTE: If a new variable group is required for any reason, make sure that you update the references to the variables groups appropriately in the `Set Deployment Type for Resource Group` PowerShell task in the** [azure-pipelines-deploy-template.yml](../azure-pipelines-deploy-template.yml) **pipeline file. Failure to do so may result in the short form of the release pipeline running when a full ARM deployment is actually required.**

## Availability Monitoring

By default the `/check` path of the azurewebsites.net URL is automatically monitored in each environment, as is the same path on the education.gov.uk domain, if configured. To add extra URLs for monitoring ensure the following format is used in the `customAvailabilityMonitors` pipeline variable for each URL you wish to monitor.

`["TEST-NAME1:DOMAIN1","TEST-NAME2:DOMAIN2"]`

The `TEST-NAMEn` should be short, unique and descriptive and contain no spaces. The `DOMAINn` should be the complete domain without the protocol specified (i.e drop the "http(s)://").

To enable email alerting for the custom URLs you must update the `alertRecipientEmails` pipeline variable for each environment as required in the following format.

`["NAME1:EMAIL1","NAME2:EMAIL2"]`

`NAMEn` is the display name for the email recipient. At the present time this name cannot contain any spaces. `EMAILn` is the email address of the recipient.

Email alerting is not configured for the `/check` domains using this approach, it only applies to any custom URLs added in the pipeline variables. If no email alerting is required, the `alertRecipientEmails` pipeline variable should be left empty or not set.
