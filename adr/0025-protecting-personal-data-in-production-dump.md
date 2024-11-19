# 25. Redacting personal data fields for local database copies

Date: 2024-11-18

## Status

Agreed

## Context

It is occasionally useful to have access to production-like data for all kinds of analysis and experiments, such as running large or dangerous migrations, analysing queries etc.

This usually becomes more apparent during an incident and that’s where this idea originates.

The first hurdle for us to overcome is deciding what we need to redact/sanitise/pseudonymise.

## Decision

### Primary / Foreign keys
These should be left alone.

### The following tables will be empty in the data dump
- active_storage_attachments
- active_storage_blobs
- active_storage_variant_records
- audits
- blazer_audits
- blazer_checks
- blazer_dashboard_queries
- blazer_dashboards
- blazer_queries
- email_clicks
- emails

### The following fields will by anonymised

| Table name          | fields                                                                                                                                                                                                                                                                                          |
|---------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| application_forms   | first_name<br/>last_name<br/>phone_number<br/>address_line1<br/>address_line2<br/>address_line3<br/>address_line4<br/>postcode<br/>disability_disclosure<br/>becoming_a_teacher<br/>equality_and_diversity<br/>safeguarding_issues<br/>international_address<br/>right_to_work_or_study_details |
| application_choices | personal_statement                                                                                                                                                                                                                                                                              |
| candidates          | email_address                                                                                                                                                                                                                                                                                   |
| find_feedback       | email_address                                                                                                                                                                                                                                                                                   |
| provider_users      | email_address<br/>first_name<br/>last_name                                                                                                                                                                                                                                                      |
| references          | email_address<br/>feedback<br/>name                                                                                                                                                                                                                                                             |
| support_users       | email_address<br/>first_name<br/>last_name                                                                                                                                                                                                                                                      |
| vendor_api_users    | full_name<br/>email_address                                                                                                                                                                                                                                                                     |

## Consequences

This is enabling work for eventually allowing developers to use production-like data in local development.
