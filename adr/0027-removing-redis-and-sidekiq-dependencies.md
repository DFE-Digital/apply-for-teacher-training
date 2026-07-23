# Removing Redis and sidekiq dependencies

Date: 2026-07-23

## Problem

Azure is removing the "Azure Cache for Redis" service. By October 2026, we will need to either move to the "Azure Managed Redis" service or remove the Redis dependency.

Historically we have used Redis / Sidekiq for our job queue. And Redis for caching. When the Apply / Manage application was created (2019) that was the expected architecture for a Ruby on Rails application. Rails has since released SolidQueue and SolidCache, native Rails solutions to the problems being solved by Redis / Sidekiq.

## Agreed / Implemented solution

We have migrated our existing caching and queuing operations to SolidCache and SolidQueue. The migration to SolidCache was completed on 27 May 2026 with [this PR](https://github.com/DFE-Digital/apply-for-teacher-training/pull/11952). The migration to SolidQueue was finalised on 22 July 2026 with [this PR](https://github.com/DFE-Digital/apply-for-teacher-training/pull/12118) and [this adjustment to the pods](https://github.com/DFE-Digital/apply-for-teacher-training/pull/12126).
