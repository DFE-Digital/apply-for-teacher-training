# Parallel Tests

This document explains how to run the test suite across multiple cores in development.

## Prerequisites

### Check development Redis config

In order to successfully run tests in parallel, each process needs its own Redis database. Configuration in [spec/spec_helper.rb](spec/spec_helper.rb) ensures that a unique database is used per test process. These are allocated from database 1 onwards.

To ensure that your development Redis isn't affected by parallel test runs, make sure that the REDIS_URL set in development is using database 0.

eg -

`REDIS_URL=redis://localhost:6379/0`

This should be handled by .env.development, but will be superseded by any local overrides.

### Prepare Postgres databases

Run the following commands.

Create additional databases:
`bundle exec rake parallel:create`

Copy development schema (repeat this after migrations)
`bundle exec rake parallel:prepare`

### Update Redis database count if needed

By default, Redis has 16 databases available numbered 0-15. We allocate databases 1-n to each process created during parallel test runs.

If you have 16 cores you'll start seeing the following error:

`ERR DB index is out of range (Redis::CommandError)`

You can fix this as follows:

- Find your Redis configuration file (eg - `/etc/redis.conf`, you can find it running `redis-cli INFO | grep 'config_file'`)
- Change the value of `databases` to CPU count + 2
  ```
  databases 18
  ```
- Restart the Redis service.

## Commands

`bundle exec parallel_rspec [folder]`

Run system specs only:

`bundle exec parallel_rspec spec/system`

Run non-system specs only:

`bundle exec parallel_rspec --exclude-pattern=spec/system spec`

## Aliases

`alias prspec='bundle exec parallel_rspec'`
