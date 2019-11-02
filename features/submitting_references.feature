@candidate @referee
Feature: references
  Candidates need two references as part of their application. When filling in the application form, they provide two sets of contact details and DfE then prompts the referees for feedback once the candidate has submitted the form.

  If a referee don't provide a reference within a certain period of time, a candidate is allowed to swap out that referee for another one. Candidates can't remove or swap out references once they've been submitted by the referees.

  Providers don't see the application form until the references have both come back.

  At Apply 2, the references are carried over from Apply 1.

  Scenario: an application isn't complete until it's received two references
    Given an application choice has "unsubmitted" status
    And the candidate has specified "j.moriarty@uni.ac.uk" and 's.skinner@springfield-elementary.edu' as referees
    And the candidate takes action "submit"
    Then the new application choice status is "awaiting_references"
    When "j.moriarty@uni.ac.uk" provides a reference
    Then the new application choice status is "awaiting_references"
    When "s.skinner@springfield-elementary.edu" provides a reference
    Then the new application choice status is "application_complete"
