[![View performance data on Skylight](https://badges.skylight.io/status/t8bEzG0cuIkd.svg?token=DyA4EBS-3afq5chyapLv4flZ-4OIXwuVKrYxtrA7b5M)](https://www.skylight.io/app/applications/t8bEzG0cuIkd)

# Apply for teacher training

A service for candidates to [apply for teacher training](https://www.apply-for-teacher-training.service.gov.uk/candidate).

![Screenshot of the candidate-facing interface](docs/apply-screenshot.png)

## Live environments

| Name       | URL                                                                  | Description                                                           | AKS namespace    |
| ---------- | -------------------------------------------------------------------- | --------------------------------------------------------------------- | ---------------- |
| Production | [www](https://www.apply-for-teacher-training.service.gov.uk)         | Public site                                                           | `bat-production` |
| Sandbox    | [sandbox](https://sandbox.apply-for-teacher-training.service.gov.uk) | Demo environment for software vendors who integrate with our API      | `bat-production` |
| Staging    | [staging](https://staging.apply-for-teacher-training.service.gov.uk) | For internal use by DfE to test deploys                               | `bat-staging`    |
| QA         | [qa](https://qa.apply-for-teacher-training.service.gov.uk)           | For internal use by DfE for testing. Automatically deployed from main | `bat-qa`         |

## Table of Contents

- [Overview](#how-the-application-works)
- [Dependencies](#dependencies)
- [Development environment](#development-environment)
- [DfE Sign-in](#dfe-sign-in)

## Guides

### Infra
- [Deploy the application](/docs/developer/deployment.md)
- [Environment variables](/docs/environment-variables.md)
- [Pipeline Variables](/docs/infra/pipeline-variables.md)
- [Restore a database](/docs/infra/database-restore.md)
- [Set up a new environment](/docs/infra/new-environment.md)
- [Swapping App Service Slots](/docs/infra/swap-slots-pipeline.md)
- [Docker for DevOps](/docs/infra/docker-for-devops.md)

### Dev
- [Developer on-boarding](/docs/developer/developer-onboarding.md)
- [Rails components](/docs/developer/components.md)
- [Understanding the different course option fields](/docs/developer/course-options.md)
- [Developing in GitHub Codespaces](/docs/developer/codespaces.md)
- [Adding PostgreSQL extensions](/docs/developer/postgres_extension.md)
- [Frontend development](/docs/developer/frontend.md)

### General
- [Connect to a production database](/docs/developer/connecting-to-databases.md)
- [Testing style guide](/docs/developer/testing-styleguide.md)
- [Performance monitoring](/docs/infra/performance-monitoring.md)

## How the application works

The application has a number of different interfaces for different types of users:

![Diagram of the Apply interfaces](docs/architecture-context.svg)

### Architecture

![Diagram of the technical architecture](docs/tech-architecture.svg)

We keep track of architecture decisions in [Architecture Decision Records (ADRs)](/adr).

### Domain Model

![The domain model for this application](docs/domain-model.png)

For simplicity the auditing table is not displayed in the diagram, as it is connected to most tables in the database.

Regenerate this diagram with `bundle exec rake erd`.

### Application states

[See detailed documentation here](docs/states.md)

### Apply APIs

This app provides several APIs for programmatic access to the Apply service. [Read about them here](/docs/development/apply-apis.md).

## Dependencies

### Production dependencies

- [Ruby](.ruby-version) 3.2.3
- Node.js – 20.11.0
- Yarn – 1.22.19
- PostgreSQL – 14
- Redis – 6.0.x

### Development dependencies

See [Developer setup](docs/development/developer-setup.md)

[Developer setup](docs/development/developer-setup.md)

## Review apps

When a new PR is opened, you have the option to deploy a review app into the `bat-qa` namespace. A deployment is initiated by adding the `deploy` label either when the PR is created or retrospectively. The app is destroyed when the PR is closed.

Review apps have `HOSTING_ENVIRONMENT` set to `review`, an empty database which gets seeded with local dev data, and a URL which will be `https://apply-review-{PR_NUMBER}.test.teacherservices.cloud/candidate/account/`.

Management of review apps follow the same processes as our standard AKS based apps.

## License

[MIT Licence](LICENCE)
