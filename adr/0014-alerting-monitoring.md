# 14. Alerting and Monitoring

Date: 2020-08-03

## Status

Accepted

## Context

The team have recently discussed Apply's approach to alerting. By alerting we mean that we are notified when:

1. There's is an outage
2. The service is partially down, like DfE Signin or a specific feature
3. Candidates cannot make applications, though no errors are thrown. For example because of a bug.
4. The system is performing so slowly that it's not usable
5. Before there's an outage

We currently have the following setup for alerting us that something is wrong:

- Azure availability alerts. Azure checks [the healthcheck endpoint](https://www.apply-for-teacher-training.service.gov.uk/integrations/monitoring/all). This checks if the application has database connectivity and is processing background jobs correctly. Azure availability tests records failure only on the third failed attempt and we are notified ~5 minutes after a failure.
- Smoke tests [run after each deploy](https://github.com/DFE-Digital/apply-for-teacher-training-tests). These tests sign in to the service and make sure that the service is usable.
- Sentry [tells us when exceptions occur](https://sentry.io/organizations/dfe-bat).

We've discussed expanding the things we alert for. For example, we could alert on lower-level technical issues like disk space, memory leaks, or high CPU. These alerts could potentially give us advance warning of infrastructure issues.

## Decision

**We will not add monitoring for low-level system metrics** as we have confidence in Azure (it's been running fine for months now) and we have confidence our current smoke tests and availability tests will pick up major problems.

There's a small chance that lower-level alerts would alert us sooner. However, they increase the chance of false positives and over-alerting.

We're choosing symptom-based monitoring over cause-based monitoring, as [described by the Google SRE handbook](https://docs.google.com/document/d/199PqyG3UsyXlwieHaqbGiWVa8eMWi8zzAn0YfcApr8Q/edit).

**We will continue to be alerted in Slack** for service availability and Sentry exceptions, and we will continue to improve our smoke tests

## Consequences

We'll continue as we do now, improving the availability check, smoke tests and Sentry set up.
