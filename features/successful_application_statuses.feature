@candidate @provider
Feature: successful application statuses

  Unsubmitted
  ========================================
  When a candidate has filled in their email address, they've started an application. Until they submit their application to a provider, it is in the unsubmitted state.

  Awaiting references
  ===================
  Applicants submit their application choices with list of referees. Until 2 references have been received the application remains at the Awaiting References state.
  The providers don't see the application at this stage.

  Application complete
  ====================
  After the references have come back and have been added to the application
  the application moves to the Application Complete state.  The providers don't
  see the application at this stage in order to give candidates a fixed period
  of time to modify their application.

  Awaiting provider feedback
  ==========================
  The providers only see the application after the references have come back
  and have been added to the application and a period of time has elapsed for
  the candidate to review and modify the application.  When both of these
  prerequisites are met the application moves to the Awaiting Provider Feedback
  state.

  Offers & meeting conditions
  =======================================
  A provider makes an offer to the candidate. The candidate then has to accept
  or reject the offer, which sets the application status to 'Pending
  conditions'.  We assume that all offers have some conditions, even if there
  are no academic conditions.

  Recruited
  =========
  If the candidate has met all conditions of their offer, the provider marks
  their application as 'recruited'.

  Enrolment
  =========
  Once a candidate has completed the enrolment process, the provider confirms
  their enrolment onto the training programme. Since this status would be used
  to claim bursaries/grants from DfE, the provider may delay enrolling the trainee
  until a few weeks after the start of the training, since trainees can still
  not show up on the first day or drop out within the first couple of weeks.
  This reduces the risk that DfE over-pays that provider for training they didn't
  deliver and having to reconcile or claw back that money later on.

  Rejected
  ========
  If a candidate turns down an offer it moves to the Rejected (end) state.

  Withdrawn
  =========
  If a candidate withdraws an application in progress it moves to the Withdrawn (end) state.

  Scenario Outline: A successful application changes status depending on candidate, referee and provider actions.
    Given an application choice has "<original status>" status
    When the <actor> takes action "<action>"
    Then the new application choice status is "<new status>"

    Examples:
      | original status            | actor     | action                 | new status           |
      | unsubmitted                | candidate | submit                 | awaiting references  |
      | awaiting_references        | candidate | withdraw               | withdrawn            |
      | awaiting_references        | candidate | references_complete    | application_complete |
      | application complete       | candidate | withdraw               | withdrawn            |
      | awaiting provider decision | provider  | make offer             | offer                |
      | awaiting provider decision | provider  | reject application     | rejected             |
      | awaiting provider decision | candidate | withdraw               | withdrawn            |
      | offer                      | candidate | accept                 | pending conditions   |
      | offer                      | candidate | decline                | declined             |
      | pending conditions         | provider  | confirm conditions met | recruited            |
      | pending conditions         | candidate | withdraw               | withdrawn            |
      | recruited                  | provider  | confirm enrolment      | enrolled             |
      | recruited                  | candidate | withdraw               | withdrawn            |
