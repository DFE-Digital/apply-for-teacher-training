# Parallel Tests

This document explains how to run the test suite across multiple cores in development.

## Prerequisites

### Prepare Postgres databases

Run the following commands.

Create additional databases:
`bundle exec rake parallel:create`

Copy development schema (repeat this after migrations)
`bundle exec rake parallel:prepare`

## Commands

`bundle exec parallel_rspec [folder]`

Run system specs only:

`bundle exec parallel_rspec spec/system`

Run non-system specs only:

`bundle exec parallel_rspec --exclude-pattern=spec/system spec`

## Aliases

`alias prspec='bundle exec parallel_rspec'`
