@candidate @referee
Feature: references
  Candidates need two references as part of their application. When filling in the application form, they provide two sets of contact details and DfE then prompts the referees for feedback once the candidate has submitted the form.

  Swapping out referees
  =====================
  If a referee don't provide a reference within a certain period of time, a candidate is allowed to swap out that referee for another one. Candidates can't remove or swap out references once they've been submitted by the referees.

  Cooling-off period
  ==================
  Providers don't see the application form until the references have both come back and 5 working days have elapsed since application submission.

  Apply 2
  =======
  At Apply 2, the references are carried over from Apply 1.

  Scenario Outline: an application is sent to a provider after it's received two references and 5 working days elapse after submission
    Given the candidate submits a complete application
    When <number of complete references> referees complete the references
    And the time is <working days since submission> working days after the form's submission
    And the daily application cron job has run
    Then the new application choice status is "<status?>"

    Examples:
      | working days since submission | number of complete references | status?                    | notes                                          |
      | 0                             | 0                             | awaiting references        | too few references                             |
      | 6                             | 0                             | awaiting references        | too few references                             |
      | 6                             | 1                             | awaiting references        | too few references                             |
      | 0                             | 2                             | application complete       | in cooling-off period                          |
      | 4                             | 2                             | application complete       | in cooling-off period                          |
      | 5                             | 2                             | application complete       | cooling-off period lasts to the end of the day |
      | 6                             | 2                             | awaiting provider decision | cooling-off period elapsed, enough references  |
