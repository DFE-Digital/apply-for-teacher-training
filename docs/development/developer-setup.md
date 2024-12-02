# Developer Setup

- [Application Setup](#application-setup)
- [Service Dependencies Setup](#service-dependencies-setup)
  - [Metal](#metal)
  - [Docker](#docker)
- [Initial Setup](#initial-setup)
- [Running the Application](#running-the-application)

## Application setup

To run the application locally, you will need to have the following local dependencies installed:

- [`ruby`](.tool-versions)
- [`node`](.tool-versions)
- Graphviz 2.22+ (`brew install graphviz`) to generate the [domain model diagram](#domain-model)
- [`chromedriver`](https://googlechromelabs.github.io/chrome-for-testing/) (you will need chromedriver and a version of Chrome installed to run the full test suite)

The recommended way to install language runtimes (ie Ruby and Node) is using
the `asdf` version manager tool ([documentation](https://asdf-vm.com/)). `asdf`
considers a file called `.tool-versions` in the repository root when deciding
which version of each language to install or use.

```bash
# The first time
asdf plugin add ruby
asdf plugin add nodejs
asdf plugin add yarn

# To install (or update, following a change to .tool-versions)
asdf install
```

To install `asdf`, read the installation guide [here](https://asdf-vm.com/guide/getting-started.html#_3-install-asdf).

## Service dependencies setup

As for running service dependencies, you have 2 options:

1. [Metal](#metal)
2. [Docker](#docker)

### Metal

Running the service dependencies requires you to have Redis and Postgres installed and running on your machine.

- `postgresql` v14
- `redis` v6

To install these dependencies, you can use a package manager like `brew` on MacOS or `apt` on Linux distros.

### Docker

As an alternative, you can use containerized dependencies. This is useful to ensure that Redis and Postgres do not conflict with other projects on your machine.

You will need to have `docker` locally installed. You can follow the instructions [here](https://docs.docker.com/get-docker/).

#### Running the service dependencies via Docker

A handy `docker-compose.yml` file has been included to simplify the process of running the dependencies. To use it, run the following command:

```bash
docker compose up
```

## Initial setup

`bin/setup` will install local dependencies and set up your database with seed data.

```bash
bin/setup
```

## Using sanitised production data

You may occasionally want to use data as close to production data as possible, for instance during an incident or when preparing for a large migration.

### 1. Downloading the sanitised data

- Login to azure and request a PIM (speak to infra or a fellow developer for instructions on how to do this)
- Once the PIM is approved, you can download the file via the azure interface by navigating Storage accounts -> `s189p01attdbbkppdsa` -> Containers (or Blob Containers) -> database-backup -> `att_backup_sanitised.sql.gz` (Warning: these instructions are true at the time of writing, but azure may change the way their interface is laid out and you might have to do some digging)
- Unzip the file, delete the zip file

### 2. Replacing your database

- run `bin/rails db:drop` and `bin/rails db:create`; do not run migrations
- run `psql bat_apply_development < ~/Downloads/att_backup_sanitised.sql` (or wherever your downloads end up)
- make sure you delete the sql file

### 3. Creating a dev-support user
The production dump won't have a support user for bypassing DFE login, so you'll need to create one before you can login to the application.

```ruby

SupportUser.create!(
  dfe_sign_in_uid: 'dev-support',
  email_address: 'support@example.com',
  first_name: 'Susan',
  last_name: 'Upport'
)
```

## Running the application

Now that you have the dependencies installed, you can run the application. The application is composed of 5 processes:

- `web` - The main Rails application
- `worker` - The background processing service
- `worker_secondary` - The secondary background processing service that prioritizes BigQuery jobs
- `clock` - The clock process that schedules recurring jobs
- `caddy` - The reverse proxy server

You can run these processes independently or use `bin/dev` command to run them all at once.

```bash
bin/dev # Ensures foreman is installed and runs all processes defined in Procfile.dev
```

### Local development

Creating and signing in to the candidate interfaces requires clicking a link
sent via email using GOV.UK Notify.

In development mode, the contents of the emails sent is saved to a log file, which
you can see by running:

```
tail -f log/mail.log
```

Signing in to the Provider interface requires a network connection and a user
account on DfE Sign-in. In development you can eliminate this dependency by
setting `BYPASS_DFE_SIGN_IN=true` in your `.env` file. This replaces the sign in
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

    bundle exec rails "create_support_user[alice, alice@example.com]"

Note that only the UID is used for lookup. The email address serves only
as a label.
