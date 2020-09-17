# 9. Async and scheduled jobs

Date: 2019-11-07

## Status

Accepted

## Context

This service will need to process applications automatically and periodically in order to enforce time-dependent business rules and modify application state. Therefore, we need a way to run domain logic code outside the context of web requests, reliably and in a proactive/scheduled way.

### Findings

We have considered:

- Find-style: run jobs via the infrastructure (they use sidekiq/sidekiq\_cron)
- clockwork gem on its own
- some sort of secure API endpoint we can hit at intervals to trigger the sweep

Considering the ability to enforce time-dependent business rules is core functionality
for the service, we have decided to follow best practices and implement scheduling
and background processing properly, using a similar approach to Find, but using
clockwork instead of sidekiq\_cron.

#### Pros

- The sidekiq/clockwork combination is a proven, stable and scalable combination which can take us all the way to public launch and beyond.
- Code scheduling and organisation will be transparent, as the schedule is defined within the source code of the app and calls standard Rails workers and services. This also gives us an update path for schedules and background tasks, re-using the standard deployment pipelines, as well as auditing information through git version control.
- Because background processing will be handled by Sidekiq, failed jobs can be retried automatically.

#### Cons

- Requires additional Azure work: support multiple containers/services (web/worker/clock) and a Redis instance.

## Decision

We will add the following capabilities to the app:

#### Scheduling

This will be achieved via the ```clockwork``` gem. It alllows periodic jobs to be defined in a ruby file within the main Rails app. For example:

```ruby
# config/clock.rb

class Clock
  include Clockwork

  every(1.minute,  'SayHello') { Rails.logger.info "hi!" }
end
```

Clockwork requires the scheduling daemon to be run as a separate process to the Rails server, but it uses the same codebase, so all models/services/workers defined in Rails are available to be triggered. This extra process can be started like this: ```bundle exec clockwork ./config/clock.rb```

**Note** While many Rails server instances may be run in a scaling out/load-balancing scenario, there must only always be ONLY ONE clockwork process, otherwise tasks will be triggered multiple times. Furthermore, in production this process should be supervised and restarted, if needed.

While it is technically possible to perform any kind of processing within the 'clock' process, this is to be avoided, as any application errors could terminate the scheduler and prevent other tasks from running. Good practice suggests the 'clock' process should only be used to trigger/enqueue tasks, which are then processed within the context of a background processing system. That's why config/clock.rb should be a list of times and Sidekiq worker perform_async statements.

#### Background processing

We will use the ```sidekiq``` gem, which is the current standard for Rails background processing. This also needs to be run as a separate process (e.g. ```bundle exec sidekiq -c 5 -C sidekiq.yml```, where 5 is a concurrency setting), but it also introduces an infrastructure requirement for Redis.

Workers are usually placed within ```app/workers``` and can call any other classes within the Rails app, such as service objects to achieve their goals.

## Consequences

Some additional work will be required on Azure in order to:

- Run multiple containers as separate services on Azure, all based on the same Docker image and the same set of environment variables, but using different start commands.
- Add a Redis instance/service to the stack, ideally using an managed/hosted service with the Azure ecosystem.
- Logging will need to be adapted to distinguish between logs from different services.

These services will need to be supervised by the platform and restarted in case of errors.
