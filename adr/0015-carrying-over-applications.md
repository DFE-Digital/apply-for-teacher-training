# 15. Carrying over applications

Date: 2020-08-12

## Status

Accepted

## Context

The current recruitment cycle ends on 18th September 2020. At that point there
will be some candidates who could benefit from their application being carried
over to the next cycle. Carrying over an application means the candidate can
apply to courses in the new recruitment cycle without having to fill in the
whole application form again.

### Carrying over an application makes sense in the following states

#### Before the application reaches the provider

These applications could be carried over because the provider has not seen them yet.

- Withdrawn
- Unsubmitted
- Ready to send to provider

#### After the application can’t progress any further

These applications could be carried over because they have reached an
unsuccessful end state. Enabling candidates to turn these into fresh applications
in the next cycle makes it as easy as possible for them to try again.

- Conditions not met
- Offer withdrawn
- Offer declined
- Application cancelled
- Rejected

### Carrying over an application does not make sense in the following states

#### While the application is already under consideration by the provider

- Awaiting provider decision

#### When the application already has an offer in flight

- Offer
- Meeting conditions (i.e. offer accepted)
- Recruited

### Copying the Apply again approach

The current approach for moving applications into Apply again is to copy the
entire application (including references) and invite the user to add a new
course choice. This approach seems like it will work here too, with a couple of
extra things to take into account:

- applications that are carried over might be in Apply 1 or Apply again as the
  cycle ends. All carried-over applications should start over as Apply 1
  applications applications moving into Apply again all have complete
  references because they’ve already completed Apply 1, for which references
  are required.
- Carried over applications might have no references, references in flight, or
  completed references.

Moving the new application into the next cycle is a question of making sure its
course choices come from that cycle. As long as carrying over is only possible
once the current cycle is closed, this should present no problems because the
available courses will all come from the new cycle.

## Decision

- We will only allow applications to be carried over once the current cycle is
  over, and we’ll only allow applications in the above states
- To carry over an application, we will adopt the Apply again pattern of
  cloning the ApplicationForm and removing the courses
- We will copy references onto the carried-over application, but only if
  they’re complete. Referees who had been contacted but had not responded
  before the application was carried over will need to be cancelled.
- The applications that were carried over will remain in the database without
  any further state change
- Applications which were not yet sent to the provider at end of cycle and also
  not carried over will still be in the database — we would like to mark these
  with a new state equivalent to “incomplete at end of cycle”. This state would
  never be visible to providers.
- It’s up to the candidate whether to carry over their application, and we’ll
  give them a button to do this
