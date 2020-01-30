# Apply for teacher training

A service for candidates to apply for teacher training. We're currently in beta.

## Live environments

| Name | URL | Description | Azure ID |
| -- | -- | -- | -- |
| Production | [www.apply..](https://www.apply-for-teacher-training.education.gov.uk/candidate) | Public site | `s106p01` |
| Staging | [staging.apply..](https://staging.apply-for-teacher-training.education.gov.uk) | For internal use by DfE to test deploys | `s106t01` |
| Sandbox | [sandbox.apply..](https://sandbox.apply-for-teacher-training.education.gov.uk) | Demo environment for software vendors who integrate with our API | `s106t02` |
| QA | [qa.apply..](https://qa.apply-for-teacher-training.education.gov.uk) | For internal use by DfE for testing. Automatically deployed from master | `s106d01` |

When setting up a new environment, check you have followed [the instructions
for doing so](/docs/new-environment.md).

## Table of Contents

* [Documentation](#documentation)
* [Dependencies](#dependencies)
* [Development environment](#development-environment)
* [DfE Sign-in](#dfe-sign-in)

## Guides

* [Developer on-boarding](/docs/developer-onboarding.md)
* [Connect to a production database](/docs/connecting-to-databases.md)
* [Deploy the application](/docs/deployment.md)
* [Environment variables](/docs/environment-variables.md)
* [Frontend development](/docs/frontend.md)
* [Pipeline Variables](/docs/pipeline-variables.md)
* [Restore a database](/docs/database-restore.md)
* [Set up a new environment](/docs/new-environment.md)
* [Testing style guide](/docs/testing-styleguide.md)

## Documentation

### Architecture

We keep track of architecture decisions in [Architecture Decision Records (ADRs)](/adr).

An overview of the Azure hosted infrastructure architecture can be found in the [Azure Infrastructure](/docs/azure-infrastructure.md) document.

### Domain Model

![The domain model for this application](docs/domain-model.png)

Regenerate this diagram with `bundle exec erd`.

### Application states

![All of the states and transitions in the app](docs/states.png)

Regenerate this diagram with `bundle exec rake generate_state_diagram`.

## Dependencies

### Production dependencies

- Ruby 2.6.5
- NodeJS 8.11.x
- Yarn 1.12.x
- PostgreSQL 9.6
- Redis 5.0.x

### Development dependencies

- `docker`
- `docker-compose`
- Graphviz 2.22+ (`brew install graphviz`) to generate the [domain model diagram](#domain-model)

## Development environment

1. Copy `.env.example` to `.env` and fill in the secrets
1. Run `make setup`
1. Run `make serve` to launch the app on https://localhost:3000

See `Makefile` for the steps involved in building and running the app.

The course and training provider data in the Apply service comes from its
sister service `Find`. To populate your local database with course data from
`Find`, run `bundle exec rake setup_local_dev_data`.

Among other things, this task also creates a support user with DfE Sign-in UID
`dev-support` that you can use to log into the Support interface in your
development environment, and a provider user with the UID `dev-provider`.

### Background processing

Certain features depend on Sidekiq running. e.g. Mailers and some of the
business rules that set time-dependent state on applications. In order
to run a local version of Sidekiq you need to make sure Redis is installed and
running and then run Sidekiq. The simplest way to do that is with
`docker-compose` (see below) or `foreman`. e.g.

    $ foreman start

### Docker Workflow

Under `docker-compose`, the database uses a Docker volume to persist
storage across `docker-compose up`s and `docker-compose down`s. For
want of cross-platform compatibility between JavaScript libraries, the
app's `node_modules` folder is also stored in a persistent Docker
volume.

Running `make setup` will blow away and recreate those volumes,
destroying any data you have created in development. It is necessary
to run it at least once before the app will boot in Docker.

### Dummy data

We have a service `GenerateTestData` which generates `ApplicationChoice`s in
the database. You can specify how many `ApplicationChoice`s are created and to
which provider they are applying.

If you don't specify a provider, the `ApplicationChoice`s will be for courses
at provider code `ABC`.

**Generate 10 applications for the default provider (ABC)**

```
GenerateTestData.new(10).generate
```

**Generate 10 applications for a specific provider**

```
GenerateTestData.new(10, Provider.find_by(code: '1N1')).generate
```

## DfE Sign-in

The Provider interface at `/provider` and Support interface at
`/support` are both protected by DfE's SSO provider DfE Sign-in.

### Environments

In development, QA, and pentest we use the **Test** environment of DfE Sign-in:

[Manage console (test)](https://test-manage.signin.education.gov.uk)

```sh
# .env
DFE_SIGN_IN_ISSUER=https://test-oidc.signin.education.gov.uk
```

In staging, production and sandbox we use the **Production** environment of DfE Sign-in:

[Manage console (production)](https://manage.signin.education.gov.uk)

```sh
# .env
DFE_SIGN_IN_ISSUER=https://oidc.signin.education.gov.uk
```

### Local development

Logging in to the Provider interface requires a network connection and a user
account on DfE Sign-in. In development you can eliminate this dependency by
setting `BYPASS_DFE_SIGN_IN=true` in your `.env` file. This replaces the login
flow with a dialog allowing you to specify a DfE Sign-in UID and Email address
for your current session.

### Provider permissions

We decide what to show providers based on their DfE Sign-in UID.

To grant a user permission to view a provider’s applications, visit
/support/users/providers and create a user, specifying their DfE Sign-in UID
and the relevant provider.

### Support permissions

There is a `support_users` database table that lists all the DfE Sign-in
accounts that have access to the Support interface based on their DfE
Sign-in UID. There is only one privilege level, either you have access
to everything or nothing.

You can add a new support user using the `create_support_user` rake
task. You need to supply a DfE Sign-in UID and an email address, e.g.

    $ bundle exec rails "create_support_user[alice, alice@example.com]"

Note that only the UID is used for lookup. The email address serves only
as a label.

## Heroku review apps

When a new PR is opened, a review app is deployed via Heroku. This has a `HOSTING_ENVIRONMENT=development`, an empty database which gets seeded with local dev data, and a URL which is similar to `https://apply-for-teacher-training.herokuapp.com`. The Heroku configuration is in [`app.json`](app.json).

## License

[MIT Licence](LICENSE.md)
