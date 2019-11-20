@provider @reject
Feature: Reject by default
  An application is rejected by default (RBD) if a provider doesn't make an offer within a certain number of working days after the application has been sent to the provider.

  The provider gets full working days so if the application was submitted in work hours, that day wouldn't count towards the number of decision days. Each application has an RBD time, which is set once the provider has received the application.
  The RBD time of an application expires just before midnight on the last allowed working day. The calculation of midnight should take GMT/BST into account.

  If the RBD time has passed and the provider hasn't made an offer or rejected the application, the DfE Apply system rejects the application automatically.

  The number of decision days (that providers get) can change at various times in the recruitment cycle (e,g, it can be set to be shorter towards the end). It can also be changed (e.g. extended) for specific applications upon request from the provider or candidate (e.g. if the candidate is unable to interview within the allotted time), however this is in exceptional cases.

  Scenario: an application is sent to a provider after it's received two references and 5 working days elapse after submission
    Given the date is "2019-07-01"
    And a 3 working day time limit on "reject_by_default"
    And the candidate submits a complete application with reference feedback
    And the date is "2019-07-09"
    And the daily application cron job has run
    Then the new application choice status is "awaiting_provider_decision"
    And the reject by default date is "2019-07-12"
    When the date is "2019-07-14"
    And the daily application cron job has run
    Then the new application choice status is "rejected"
    And the application choice is flagged as rejected by default
