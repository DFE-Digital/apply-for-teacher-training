# 23. Add Active Storage with Azure Storage

**Date:** 31/05/2024

## Status:

Proposed

## Context

Our `data_exports` table currently stores csv files in binary format. This causes each row to be very large and slow to query. We want to move these files to Active Storage to improve performance and reduce the size of the table. This will also make database backups much more efficient.

## Consequences:

- We will have an additional 3rd party dependency in production - Azure Storage.
- We will need to update our CI/CD pipeline to include spinning up Azure Storage instances.
- We will need to add Azure Storage env vars to the production config.
- We will also need to backup Azure Storage accounts/containers as part of our disaster recovery plan.
