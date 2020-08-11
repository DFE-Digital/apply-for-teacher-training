# 11. Storing Diversity Data

Date: 2019-01-14

## Status

Accepted

## Context

This service will need to store sensitive diversity data for each candidate - gender, ethnicity, etc - which, although of little interest to attackers, would be potentially impactful to the candidate if someone was to gain unauthorised access to it. Therefore we need to take extra care to minimise the risk of this happening.

## Findings

The risks and threats we considered:

1. Non-malicious but still unauthorised access. For instance, a genuine provider or support user just clicking around out of interest, or to check up on a family member, etc

2. SQL-injection-style attack: "script kiddies" applying as Mr ';SELECT * FROM Candidates;', etc

3. Application bug accidentally dumping too much data into the response

4. Accidental exposure through opsec breach. For instance, leaving unencrypted backups on publicly-accessible file store, etc

Options we have considered:

### 1. One app, two databases

Storing the data in a separate database within the same infrastructure and ops setup

#### Pros

- Rails 6 has native support for multiple databases
- Most performant of the separate-datastore solutions

#### Cons

- Possibly _too_ transparent to the app/developers - if it presents _too_ much like the same database, we'll have the constant cognitive overhead of trying to do things like cross-database joins, and then wasting time while we remember that "oh yes, _that's_ why it did not work..."
- Ops overhead - all DB management tasks will need to be scoped to the database (applying migrations, etc), deploy chain needs extending to support multiple databases, multiple environment variables with database URLs, multiple backups, etc
- Adds complexity to an already quite-heavyweight single application
- Not much separation in practice

### 2. Completely separate microservice

Creating a separate microservice with a dedicated RESTful API, deployed as an entirely separate standalone application.

#### Pros

- Fully isolated
- Access can be managed, logged and monitored entirely separately
- Clear in Apply codebase that it's a remote call
- Keeps each app inside the default single-database assumption

#### Cons

- Operationally complex to set up
- Needs entirely separate monitoring, deploy pipeline, backups, etc
- Creates a hard dependency on a synchronous remote call in Apply (for retrieving & storing data)

### 3. Dedicated microservice in the same application

Similar to option 2 above, but deploying the separate microservice & database as a separate container within the same infrastructure and ops setup

#### Pros

- Access can be managed, logged and monitored entirely separately
- Clear in Apply codebase that it's a remote call
- Keeps each app inside the default single-database assumption
- Keeps all Apply infrastructure & components within the Apply CIP setup
- Data transfer between the Apply app and the diversity microservice can be kept inside the Apply 'firewall'

#### Cons

- Adds complexity to monitoring
- Adds complexity to deployment pipeline
- Adds a hard dependency on a synchronous remote call within Apply

### 4. Not storing the data at all

Pushing back on the need for our service to collect & store the data, when we would only be doing so to give it to the providers

#### Pros

- Adds no complexity at all to us

#### Cons

- Pushes complexity back to the user's experience - if they're going to have to provide this data, it makes most sense for them to do so at the point when they're already providing the rest of their data (at the point of submitting their application)


### 5. Worrying less about storage, more about access

Accepting the risk of not separating the data at the point of storage, and focussing our efforts on separation at the point of access

We can store the diversity data in a separate table, providing some slight mitigation against SQL-injection attack (the attacker needs to know the table name & join conditions).

We can mitigate risk 1 (non-malicious but still unauthorised access) through a couple of enhancements:
- only show the diversity data in the provider UI on a separate page, potentially with an interstitial reminder to the user that the data they're about to view is sensitive and their access will be logged & audited. This will at least make the casual browser think twice before proceeding

- do not include the diversity data within the `/applications/(id)` endpoint, but only on a separate sub-resource endpoint (`/applications/(id)/diversity_data` or similar)

For both of the above dedicated URLs, access can be logged, monitored, audited and even alerted on with simple config changes to existing tooling.

## Decision

For all of the solutions except 4 (not storing the data at all), the Apply app will still need to decrypt the data to present it in the API and UI as plain text to the Student Records Systems or the user. So however we store the data, we would have added complexity in the code and the operations management, yet still be vulnerable to all the considered risks (except risk 2 - SQL injection - we have framework-level protection against this, and our most recent pen test found no SQL-injection vulnerabilities).

We have discounted solution 4 as the user should not have to deal with the complexity involved - we should be aiming to offer the best possible user experience, and this is not it.

Therefore we have decided to pursue option 5 - concentrating on separation of the data at the point of the access.
