# Developer Setup

## Local dependencies

The most common way to run a development version of the application is run with local dependencies.

### Local development dependencies

- `postgresql` v14
- `redis` v6
- Graphviz 2.22+ (`brew install graphviz`) to generate the [domain model diagram](#domain-model)
- [`ruby`](.tool-versions)
- [`nodejs`](.tool-versions)
- [`chromedriver`](https://googlechromelabs.github.io/chrome-for-testing/) (you will need chromedriver and a version of Chrome installed to run the full test suite)

The recommended way to install language runtimes (ie Ruby and Node) is using
the `asdf` version manager tool ([documentation](https://asdf-vm.com/)). `asdf`
considers a file called `.tool-versions` in the repository root when deciding
which version of each language to install or use.

On a mac:

```bash
# The first time
brew install asdf
asdf plugin add ruby
asdf plugin add nodejs
asdf plugin add yarn

# To install (or update, following a change to .tool-versions)
asdf install
```

## Running the app

 1. [Metal](#metal)
 2. [Docker](#docker)

### Metal

1. Install the dependencies listed above
2. Make sure Redis and Postgres are running as services
3. Run [`bin/setup`](bin/setup)

If something is missing, fill in any *required* missing secrets in `.env`

#### Custom local db setup

If there are problems with the database setup, you might want to set environment variables in `.env`:

1. Start the postgres service: `sudo service postgresql start` on Linux or `brew services start postgresql` on Mac
2. Populate the `DB_` relevant environment variables with the correct values (those are: `DB_USERNAME`, `DB_PASSWORD`, `DB_HOSTNAME` and `DB_PORT`)
3. Rerun `bin/setup`

### Running the app

To run the application locally:

Run `bin/rails s` to launch the app on <http://localhost:3000>


## Docker

As an alternative to that, it's also possible to run the application in Docker:

### Docker dependencies

- `docker`
- `docker-compose`
- Graphviz 2.22+ (`brew install graphviz`) to generate the [domain model diagram](#domain-model)

### Running the app

Install the above dependencies, and then:

1. Run `make setup`
2. Run `make serve` to launch the app on <https://localhost:3000>

See `Makefile` for the steps involved in building and running the app.

### Docker Workflow

Under `docker-compose`, the database uses a Docker volume to persist
storage across `docker-compose up`s and `docker-compose down`s. For
want of cross-platform compatibility between JavaScript libraries, the
app's `node_modules` folder is also stored in a persistent Docker
volume.

Running `make setup` will blow away and recreate those volumes,
destroying any data you have created in development. It is necessary
to run it at least once before the app will boot in Docker.

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

## Background processing (Foreman)

Certain features depend on Sidekiq running. e.g. Mailers and some of the
business rules that set time-dependent state on applications. In order
to run a local version of Sidekiq you need to make sure Redis is installed and
running and then run Sidekiq. The simplest way to do that is with
`docker-compose` (see below) or `foreman`. e.g.

    foreman start

See the [`Procfile`](Procfile) to understand what processes are being managed.

