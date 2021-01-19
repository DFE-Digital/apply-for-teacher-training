# Pipeline variables

The pipeline variables can be found in [Azure DevOps](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_library?itemType=VariableGroups)

Each environment has three tiers of pipelines variables, listed below and starting with the least specific first.
1. `Docker Shared Variables` - This group is common to all environments in Apply and also Find. It contains the login credentials from Dockerhub used during the build and deployment processes.
1. `APPLY - Shared Variables` - This group is used for all environment deployments in Apply only and covers credentials and configuration common to all of Apply's environment.
1. `APPLY - ENV - EnvironmentName` - These groups are named in correspondance with the envioronments to which they apply and contain credentials and configuration variables specific to those environments.

**NOTE: If a new variable group is required for any reason, make sure that you update the references to the variables groups appropriately in the `Set Deployment Type for Resource Group` PowerShell task in the** [deploy.yml](../azure/pipelines/templates/deploy.yml) **pipeline file. Failure to do so may result in the short form of the release pipeline running when a full ARM deployment is actually required.**

## Availability Monitoring

By default the `/check` path of the azurewebsites.net URL is automatically monitored in each environment, as is the same path on the education.gov.uk domain, if configured. To add extra URLs for monitoring ensure the following format is used in the `customAvailabilityMonitors` pipeline variable for each URL you wish to monitor.

`["TEST-NAME1:DOMAIN1","TEST-NAME2:DOMAIN2"]`

The `TEST-NAMEn` should be short, unique and descriptive and contain no spaces. The `DOMAINn` should be the complete domain without the protocol specified (i.e drop the "http(s)://").

To enable email alerting for the custom URLs you must update the `alertRecipientEmails` pipeline variable for each environment as required in the following format.

`["NAME1:EMAIL1","NAME2:EMAIL2"]`

`NAMEn` is the display name for the email recipient. At the present time this name cannot contain any spaces. `EMAILn` is the email address of the recipient.

Email alerting is not configured for the `/check` domains using this approach, it only applies to any custom URLs added in the pipeline variables. If no email alerting is required, the `alertRecipientEmails` pipeline variable should be left empty or not set.

### Alerts into Slack

If the `alertRecipientEmails` pipeline variable has been set on an environment it will automatically configure alerting into Slack too. The default channel used for alerts is `#twd_apply_devops` however this can be changed globally or on a per environment basis by setting the `alertSlackChannel` pipeline variable.

*NOTE: The first time Slack alerting is deployed into an environment the API connection to Slack will require authorisation. The process for this can be found in the [BAT Building Blocks repo readme file](https://github.com/DFE-Digital/bat-platform-building-blocks#logic-app-for-slack).*

Diagnostic logs for the Logic App runs can be found in the Azure portal in the "Logic Apps" blade. From this view you can select the Logic App corresponding to the target environment where the run history is displayed. Longer term log retention is in the Azure storage account linked to the environment. To see the storage account used for log retention click on "Diagnostic settings" under the "Monitoring" section of the Logic App blade menu, the displayed table shows the storage account used for the log retention. You can access the retained logs by browsing through the folder structure in the storage containers in the storage account.
