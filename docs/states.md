# Application States (#status)


`ApplicationChoice` uses a State Machine to manage the states the model can be in.

We use a library called [workflow](https://github.com/geekq/workflow) to manage this.

The workflow definition is stored in [ApplicationStateChange](https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/app/services/application_state_change.rb).


## Current States

This is a table of all the states that an ApplicationChoice can have.


|State                         | Description|
|---                           | ---|
| `application_not_sent`       | Applications are set to this state at the end of the cycle if they are `unsubmitted` |
| `awaiting_provider_decision` | Submitted and waiting for provider decision |
| `cancelled`                  | DEPRECATED |
| `conditions_not_met`         | Submitted, accepted but offer conditions were not met by the candidate |
| `declined`                   | Offer by the provider is declined |
| `inactive`                   | Application has been in `awaiting_provider_decision` for more than 30 days |
| `interviewing`               | An interview is created by the provider for the candidate |
| `offer`                      | Application has received an offer from the provider |
| `offer_deferred`             | An offer has been deferred to next recruitement cycle |
| `offer_withdrawn`            | Provider withdraws an offer |
| `pending_conditions`         | Provider makes and offer and the candidate must meet conditions of the offer |
| `recruited`                  | Unconditional offer is accepted or offer conditions have been met |
| `rejected`                   | Application is rejected by provider accompanied by structured reasons|
| `unsubmitted`                | Candidate has added the course to their application form but has not submitted it yet |
| `withdrawn`                  | Submitted application has been withdrawn by the candidate (or by the provider on behalf of the canidate) |

## State Categories

These are groupings of states that allow us to define behaviour for a any application whose status is in the group.

|Category|States|Description|
|---|----|---|
|STATES_NOT_VISIBLE_TO_PROVIDER |unsubmitted<br>cancelled<br>application_not_sent|Applications that have not been submitted and so do not concern providers|
|STATES_VISIBLE_TO_PROVIDER|awaiting_provider_decision<br>interviewing<br>offer<br>pending_conditions<br>recruited<br>rejected<br>declined<br>withdrawn<br>conditions_not_met<br>offer_withdrawn<br>offer_deferred<br>inactive|The opposite of STATES_NOT_VISIBLE_TO_PROVIDER. [Some of these states are aliased in the API](https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/app/presenters/vendor_api/application_presenter.rb#L11) |
|INTERVIEWABLE_STATES|awaiting_provider_decision<br>interviewing<br>inactive|States in which an application can have an interview created for them|
|ACCEPTED_STATES|pending_conditions<br>conditions_not_met<br>recruited<br>offer_deferred|The states that are possible once a provider has made an offer and the candidate has accepted.|
|OFFERED_STATES|ACCEPTED_STATES<br>declined<br>offer<br>offer_withdrawn|All states possible if a provider wants to offer a candidate a place|
|POST_OFFERED_STATES|ACCEPTED_STATES<br>declined<br>offer_withdrawn|All states possible from the offer state|
|UNSUCCESSFUL_STATES|withdrawn<br>cancelled<br>rejected<br>declined<br>conditions_not_met<br>offer_withdrawn<br>application_not_sent<br>inactive|Applications that have ended in a state that is not recruited|
|SUCCESSFUL_STATES|pending_conditions<br>offer<br>offer_deferred<br>recruited|Applications that have received an open offer, or have been deferred or recruited|
|DECISION_PENDING_STATUSES|awaiting_provider_decision<br>interviewing|Applications which can move to an offer or rejected state|
|DECISION_PENDING_AND_INACTIVE_STATUSES|awaiting_provider_decision<br>interviewing<br>inactive||
|REAPPLY_STATUSES|rejected<br>cancelled<br>withdrawn<br>declined<br>offer_withdrawn|If an pplication is in these states, the candidate can apply for the course again|
|TERMINAL_STATES|UNSUCCESSFUL_STATES<br>recruited|Used only in ApplicationMonitor (SupportInterface)|
|IN_PROGRESS_STATES|DECISION_PENDING_STATUSES<br>ACCEPTED_STATES<br>offer|Applications which have been submitted and are still under consideration|
