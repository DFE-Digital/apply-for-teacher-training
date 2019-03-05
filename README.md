[![Build Status](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_apis/build/status/Apply/apply-for-postgraduate-teacher-training?branchName=vsts_build_and_deploy)](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_build/latest?definitionId=49&branchName=master)

# Apply for postgraduate teacher training

**Apply for postgraduate teacher training** is a service for candidates to apply to intitial teacher training courses.

## Installing and running

### Dependencies

#### Install Ruby

You will need to install [Ruby](https://www.ruby-lang.org/en/) first, see the `.ruby-version` file for the
version of Ruby to install.

#### Install Yarn

Install the latest version of [Yarn](https://yarnpkg.com/lang/en/) to install
frontend libraries.

#### Install PostgreSQL

Install [PostgreSQL 10](https://www.postgresql.org).

#### Install gems

Install [Bundler](https://bundler.io) first.

```
gem install bundler
```

Then install gems.

```
bundle install
```

#### Install frontend libraries

Do this with Yarn, not npm.

```
yarn install
```

### Running

#### Setting up the database

Start PostgreSQL before proceeding. Then set up the database.

```
bundle exec rails db:setup
```

#### Running Rails

Run the rails server.

```
bundle exec rails server
```

Then access the website at [localhost:3000](http://localhost:3000).

Optionally, run the Rails console.

```
bundle exec rails console
```

#### Run all tests and checks

You can run all tests and checks with:

```
bundle exec rake
```

See below how to run individual tasks.

#### Running tests

We have RSpec tests that live in `spec/` as well as Cucumber features that live
in `features/`.

Run [RSpec](http://rspec.info) tests with:

```
bundle exec rspec
```

Run [Cucumber](https://cucumber.io) tests with:

```
bundle exec cucumber
```

#### Running linters

We have linters from [govuk-lint](https://github.com/alphagov/govuk-lint).

Run the Ruby linters with:

```
bundle exec lint:ruby
```

Run the SCSS linters with:

```
bundle exec lint:scss
```

#### Running Guard

Guard can automatically run tests when files change. To take advantage of this,
start Guard:

```
bundle exec guard
```

## Architecture Decision Record

See this [Google Doc](https://docs.google.com/document/d/1hjKIBRid-4-9X5oZVaQdsYTs-2sXN9Vr8N88DzulvG0/edit?usp=sharing)
