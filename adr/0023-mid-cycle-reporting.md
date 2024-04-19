# 23. Mid-cycle Reporting

**Date:** 19/04/2024

## Status:

Proposed


## Context

Last cycle we created a static “Mid-cycle Report”, viewable by Provider users in Manage, based on an uploaded CSV file (done only once). See Design History: Letting training providers view their recruitment performance.

This year we are proposing a dynamic per-provider report in Manage of candidate-level statistics, with a metric showing the number of candidates with “no response > 30 days” (i.e. candidates that have an ‘Inactive’ application with this provider).
We will use the existing format & content as our baseline for an appropriately amended design.

## Proposition:

The previous implementation of the mid-cycle report (2022-23) should be removed as the data will be significantly different from this years report - this year has a Candidate focus rather than Application focus.
As such we have decided to remove the mid-cycle report from the UI and purge the data.

The new report will use a combination of last year's UI blended with data concepts used in the implementation of Monthly Reporting.

We have decided to sync data for each provider in the early hours of Monday morning as this is when the refreshed data is available from BigQuery. We will consider the scenario of the data not being available for the current week in BigQuery - in which case we should not attempt to update the data in Manage.

When syncing data we have 2 options, 1. we can create a new record for each provider and year+week number (1 row is a Provider's data for a given week in a year) or 2. we can update a single row for each provider on each update (1 row is a Provider's most recent data) - TBC

*[TBC]: To be confirmed
