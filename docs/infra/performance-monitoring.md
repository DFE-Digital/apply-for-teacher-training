# Performance monitoring

## External Integrations

### Skylight

skylight.io provides a rich set of performance monitoring tools, available form
on the apps [dashboard page](https://www.skylight.io/app/applications/t8bEzG0cuIkd).

#### Configuring in deployed environments

In a deployed environment, the environment variable
`SKYLIGHT_AUTH_TOKEN` should be set to the auth token available
from the application setting in skylight.io.

To enable Skylight for a given environment, the environment variable `SKYLIGHT_ENABLE` should be set to `true`.

#### Configuring for local development

In local development, if you need to test performance monitoring you can enable
Skylight and set the auth token in a local `.env` file with the token itself available on the
[Skylight application setting page](https://www.skylight.io/app/settings/1woC6LIhRprp/app_settings)

```
SKYLIGHT_AUTH_TOKEN=auth token goes here
SKYLIGHT_ENABLE=true
SKYLIGHT_ENV=development
```
