@candidate @provider
Feature: successful application statuses

  Unsubmitted
  ========================================
  When a candidate has filled in their email address, they've started an application. Until they submit their application to a provider, it is in the unsubmitted state.

  Application complete
  ====================
  Applicants submit their application choices for evaluation by a provider. The providers don't see the application until the references have come back and have been added to the application.

  TODO: while references are still being collected, is the application in an 'unsubmitted' or in an 'application complete' status?

  Conditional offers & meeting conditions
  =======================================
  A provider makes a conditional offer to the candidate. The candidate then has
  to accept the offer, which sets the application status to 'meeting conditions'.

  Unconditional offers
  ====================
  A provider makes an unconditional offer to the candidate. Once the candidate
  accepts this offer, the application then goes into 'recruited' status.

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

  Scenario Outline: A successful application changes status depending on candidate, referee and provider actions.
    Given an application choice has "<original status>" status
    When the <actor> takes action "<action>"
    Then the new application choice status is "<new status>"

    Examples:
      | original status       | actor     | action                   | new status               |
      | unsubmitted           | candidate | submit                   | application complete     |
      | application complete  | provider  | make conditional offer   | conditional offer        |
      | application complete  | provider  | make unconditional offer | unconditional offer      |
      | conditional offer     | candidate | accept                   | meeting conditions       |
      | meeting conditions    | provider  | confirm conditions met   | recruited                |
      | unconditional offer   | candidate | accept                   | recruited                |
      | recruited             | provider  | confirm enrolment        | enrolled                 |
