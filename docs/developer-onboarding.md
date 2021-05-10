# Developer On-boarding

## Purpose

This document describes the on-boardng steps for new Developers when they join the team.

## PaaS/DevOps steps

### Get a PaaS account
You can get an account by requesting one in the `#digital-tools-support` Slack channel. Request an account with a SpaceDeveloper role for your @digital.education.gov.uk email address with access to the `dfe` organisation and `bat-prod`, `bat-staging` and `bat-qa` spaces.

### Install the CloudFoundary CLI
PaaS is built on CloudFoundary and we use the CloudFoundary CLI to interact with PaaS. You can install version 7 of the CLI [here](https://github.com/cloudfoundry/cli#downloads).

### Getting started cheatsheet

First you need to authenticate via the CLI, SSO is recommended, enter
the following command and follow the instructions:
```
cf login -a https://api.london.cloud.service.gov.uk --sso
```

After authenticating you'll be prompted to pick a space:
```
Targeted org dfe-teacher-services

Select a space:
1. bat-qa
2. bat-staging
3. bat-prod

Space (enter to skip):
```

You can view available spaces and switch at any time:
```
$ cf spaces
Getting spaces in org dfe as bob.developer@digital.education.gov.uk...

name
bat-prod
bat-qa
bat-staging

$ cf target -s bat-staging
API endpoint:   https://api.london.cloud.service.gov.uk
API version:    3.99.0
user:           bob.developer@digital.education.gov.uk
org:            dfe
space:          bat-staging
```

To see the list of applications or backing services for the current
space:
```
$ cf apps

$ cf services
```
You can drill down to get a bit more detail about a particular
application using the application names given:
```
$ cf app <APP_NAME>
```

To tail logs for a given application use:
```
$ cf logs <APP_NAME>
```

If you want to see back a little further back into the logs:
```
$ cf logs <APP_NAME> --recent
```

To shell into a container:
```
$ cf ssh <APP_NAME>
```

Then you can run a rails console as follows:
```
$ cd /app
$ /usr/local/bin/bundle exec rails console 
```

A shortcut for a rails console is:
```
$ make prod|staging|qa|sandbox shell
```

(See the `Makefile` in the root directory)

You can get a list of `cf` commands and help on individual commands. e.g.:
```
$ cf --help

$ cf spaces --help
```

For more see the [official docs](https://docs.cloud.service.gov.uk/).
