# Pipeline Variables

## Availability Monitoring

By default the `/check` path of the azurewebsites.net URL is automatically monitored in each environment, as is the same path on the education.gov.uk domain, if configured. To add extra URLs for monitoring ensure the following format is used in the `customAvailabilityMonitors` pipeline variable for each URL you wish to monitor.

`["TEST-NAME1:DOMAIN1","TEST-NAME2:DOMAIN2"]`

The `TEST-NAMEn` should be short, unique and descriptive and contain no spaces. The `DOMAINn` should be the complete domain without the protocol specified (i.e drop the "http(s)://").

To enable email alerting for the custom URLs you must update the `alertRecipientEmails` pipeline variable for each environment as required in the following format.

`["NAME1:EMAIL1","NAME2:EMAIL2"]`

`NAMEn` is the display name for the email recipient. At the present time this name cannot contain any spaces. `EMAILn` is the email address of the recipient.

Email alerting is not configured for the `/check` domains using this approach, it only applies to any custom URLs added in the pipeline variables. If no email alerting is required, the `alertRecipientEmails` pipeline variable should be left empty or not set.
