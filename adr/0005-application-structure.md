# 5. Application structure

Date: 2019-09-25

## Status

Accepted

## Context

We've chosen a [monolith approach](/adr/0004-application-architecture.md) for this application. One of the consequences is that we have to think about the application structure in advance.

## Decision

We'll structure the application as follows:

![Diagram of the application structure](/adr/0005-application-structure.png)

The app layer only contains models (Candidate, Application, etc) and services (things to change state). It has no controllers or views.

The user-facing functionality is split into 3 components: Candidate, Provider and Vendor API. These namespaces do not talk to each other, but only to the app layer. Each component has their own controller hierarchy, own views, mailers, and component-specific services.

## Consequences

We'll try to use the proposed structure. We need to regularly review the structure to see if it's still appropriate.
