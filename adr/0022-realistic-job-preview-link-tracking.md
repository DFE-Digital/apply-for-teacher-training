# 22. Realistic Job Preview Link Tracking

**Date:** 18/04/2024

## Status:

Proposed

## Context

We want to encourage unsuccessful candidates to make use of an ‘RJP’ tool built by the Teacher Success team, in collaboration with a group of academics that we’ve been working with.

They will then be directed to a separate service, managed by an external party, which will tell them how suitable they are to be a teacher, and give them some pointers. We will then be given access to the data from each candidate’s engagement with this tool, should they choose to click on the link.

This link will be made available to candidates in emails we send when they are rejected, decline an offer, or withdraw. We need to think about where else we could signpost this links.

*[RJP]: Realistic Job Preview

## Proposition:

We have identified a list of Candidate facing emails that we will include the content and link in.

The link will have a `utm_campaign` parameter that will be used to track the candidate's engagement with the tool.

The DfE's [data analytics gem](https://github.com/DFE-Digital/dfe-analytics) has a mechanism for creating a unique identifier for each user, which we can replicate to generate the `utm_campaign` parameter.
We will refer to this identifier as a `pseudonymised_id`.

## Consequences:

- We will be able to track the engagement of candidates with the RJP tool.
- We will have a one way hash of a Candidates ID to use as the `pseudonymised_id`.
