# Removing Redis and sidekiq dependencies

Date: 2026-07-23

## Problem

Azure is removing the "Azure Cache for Redis" service. By October 2026, we will need to either move to the "Azure Managed Redis" service or remove the Redis dependency.

Historically we have used Redis / Sidekiq for our job queue. And Redis for caching. When the Apply / Manage application was created (2019) that was the expected architecture for a Ruby on Rails application. Rails has since released SolidQueue and SolidCache, native Rails solutions to the problems being solved by Redis / Sidekiq.

## Solution

We have migrated our existing caching and queuing operations to SolidCache and SolidQueue. In preparation for the work, we scaled our database instance to ensure we had capacity for any increased load.

The migration to SolidCache was completed on 27 May 2026 with [this PR](https://github.com/DFE-Digital/apply-for-teacher-training/pull/11952). The migration to SolidQueue was finalised on 22 July 2026 with [this PR](https://github.com/DFE-Digital/apply-for-teacher-training/pull/12118) and [this adjustment to the pods](https://github.com/DFE-Digital/apply-for-teacher-training/pull/12126).

To support our the implementation, we have Mission Control for monitoring jobs at `/support/jobs` and cache monitoring at `support/solid-cache`.

## Further work

We have agreed to continue using `clock.rb`, rather than creating a `recurring.yml` file, which would be the default implementation if we were starting a new application. In addion, we have retained the naming convention `SomeThingWorker`, in the `workers` directory. In the future, for an improved developer experience, we might wish to adopt the default implementation (`recurring.yml`, rename the workers to jobs, and the move them to a job directory), but it is not essential.

In addition, we are still monitoring failures to identify where a nuanced retry strategy may be required. SolidQueue does not implement a default retry behaviour. There are some places where we are retrying on StandardError. We have a watching brief on this.

We have agreed to scale the database back down to its previous size. There has been not notable increase in the load now that we have migrated fully to SolidQueue and SolidCache.
