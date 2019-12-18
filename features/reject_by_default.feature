@provider @reject
Feature: Reject by default
  An application is rejected by default (RBD) if a provider doesn't make an offer within a certain number of working days after the application has been sent to the provider.

  The provider gets full working days so if the application was submitted in work hours, that day wouldn't count towards the number of decision days. Each application has an RBD time, which is set once the provider has received the application.
  The RBD time of an application expires just before midnight on the last allowed working day. The calculation of midnight should take GMT/BST into account.

  If the RBD time has passed and the provider hasn't made an offer or rejected the application, the DfE Apply system rejects the application automatically.

  The number of decision days (that providers get) can change at various times in the recruitment cycle (e,g, it can be set to be shorter towards the end). It can also be changed (e.g. extended) for specific applications upon request from the provider or candidate (e.g. if the candidate is unable to interview within the allotted time), however this is in exceptional cases.

  Background:
    Given a 3 working day time limit on "reject_by_default"
    And a 5 working day time limit on "edit_by"
    And the date is "2019-01-01" # well before the application is sent to the provider
    And the candidate submits a complete application with reference feedback

  Scenario Outline: providers get a certain number of business days to make decisions on applications
    Given the time is "<provider gets application at>"
    And the daily application cron job has run
    Then the reject by default time is "<RBD time>"

    Examples:
      | provider gets application at    | RBD time                       | notes                          |
      | Mon 2 Sept 2019 9:00:00 AM BST  | Fri 6 Sept 2019 0:00:00 AM BST | app submitted during work time |
      | Mon 2 Sept 2019 11:00:00 PM BST | Fri 6 Sept 2019 0:00:00 AM BST | app submitted out of hours     |
      | Fri 30 Aug 2019 9:00:00 AM BST  | Thu 5 Sept 2019 0:00:00 AM BST | across the weekend             |
      | Mon 4 Feb 2019 11:00:00 PM GMT  | Fri 8 Feb 2019 0:00:00 AM GMT  | submissions in GMT             |
      | Fri 29 Mar 2019 9:00:00 AM GMT  | Thu 4 Apr 2019 0:00:00 AM BST  | daylight savings weekend       |

  Scenario Outline: applications without offers are rejected automatically when their RBD time has elapsed
    Given an application choice has "awaiting provider decision" status
    And its RBD time is set to "<RBD time>"
    When the time is "<current time>"
    And the daily application cron job has run
    Then the new application choice status is "<new application state>"
    And the application choice is <flagged as RBD?> as rejected by default

    Examples:
      | RBD time             | current time         | new application state      | flagged as RBD? | notes                   |
      | 23 May 2019 11:59:59 | 23 May 2019 11:59:58 | awaiting provider decision | not flagged     | RBD time not yet passed |
      | 23 May 2019 11:59:59 | 24 May 2019 00:00:00 | rejected                   | flagged         | RBD time passed         |
