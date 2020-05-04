# 13. Course Option Validity

Date: 2020-05-01

## Status

Accepted

## Context

We define a course option as a specific combination of (course, study mode, site). A course has several sites, and each site may offer the course in full time or part time modes. Every course option we create for a course covers one of the combinations.

We've recently completed a series of iterations that deal with:

- course options falling into a state that means they are no longer valid choices for an application
- how to deal with options that fall into this state after they've already been added to a candidate's application

This ADR summarises the design choices made during this phase of work and provides an overview of how various course option states are handled.

## Decision

The service currently stops an application being submitted (via error messages on submission) in the following cases:

- The course is full (ie - it has no vacancies at any of its course options)
- The course has been withdrawn by the provider from Find.
- The course has been closed by us on Apply.
- The specific course option chosen by the candidate is full (but other course options have vacancies).

There's a fifth state we handle as well:

- Upon syncing, the Find API tells us that a specific site is no longer related to a course.

For these cases, we:

- try and delete the course options for this site/course combo, OR
- if the course option is part of a candidate's application we set the field `site_still_valid` to `false` and notify support instead.


## Consequences

- We now handle the majority of known 'invalid' course option states.
- There is further analysis underway to decide if, when stopping app submission, it's worthwhile distinguishing between site vacancy and study mode vacancy.
