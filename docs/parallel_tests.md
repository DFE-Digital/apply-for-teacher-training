# Parallel Tests

This document explains how to run the test suite across multiple cores in development.

## Prerequisites

### Check environment

Ensure that REDIS_URL is not present in .env.test or .env.

In order to successfully run tests in parallel, each process needs its own Redis database. We determine the Redis database id in [ApplyRedisConnection](app/lib/apply_redis_connection.rb). This class always uses REDIS_URL if present in the environment. In order for it to return the appropriate URL for test runs, we need to ensure REDIS_URL is not set in the test environment.

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

- Find your Redis configuration file (eg - /etc/redis.conf)
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
