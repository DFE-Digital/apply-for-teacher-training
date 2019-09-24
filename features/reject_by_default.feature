@provider @candidate
Feature: Reject by default

  An application is rejected by default (RBD) if a provider doesn't make an offer
  within a certain number of working days after the application is submitted.

  Refer to the 'working days' spec to see how a working day is defined.

  The provider gets full working days so if the application was submitted in work
  hours, that day wouldn't count towards the number of decision days. Each application
  has an RBD time, which is just before midnight on the last allowed working day.
  The calculation of midnight should take GMT/BST into account.

  If the RBD time has passed and the provider hasn't made an offer or rejected
  the application, then the DfE Apply system rejects the application automatically.

  The number of decision days (that providers get) can change at various times
  in the recruitment cycle (e.g. it can be set to be shorter towards the end).
  It can also be changed (e.g. extended) for specific applications upon request
  from the provider or candidate (e.g. if the candidate isn't able to attend the
  interview within the allotted time) but this is an exceptional case and would
  need to be handled through support.

  Background:
    Given there are no holidays

  Scenario Outline: the 'reject by default' (RBD) date on an application
    Given the following decision timeframes:
      | application submitted after | application submitted before | type              | # of working days |
      | 1 Oct 2018 0:00:00          | 15 Sept 2019 23:59:59        | reject by default | 3                 |
    When an application is submitted at "<submission time>"
    Then the application's RBD time is "<RBD time>"

    Examples:
      | submission time                 | RBD time                       | notes                          |
      | Mon 2 Sept 2019 9:00:00 AM BST  | Fri 6 Sept 2019 0:00:00 AM BST | app submitted during work time |
      | Mon 2 Sept 2019 11:00:00 PM BST | Fri 6 Sept 2019 0:00:00 AM BST | app submitted out of hours     |
      | Fri 30 Aug 2019 9:00:00 AM BST  | Thu 5 Sept 2019 0:00:00 AM BST | across the weekend             |
      | Mon 4 Feb 2019 11:00:00 PM GMT  | Fri 8 Feb 2019 0:00:00 AM GMT  | submissions in GMT             |
      | Fri 29 Mar 2019 9:00:00 AM GMT  | Thu 4 Apr 2019 0:00:00 AM BST  | daylight savings weekend       |

  Scenario Outline: the 'reject by default' (RBD) decision time can change at different parts of the recruitment cycle
    Given the following decision timeframes:
      | application submitted after | application submitted before | type              | # of working days |
      | 1 Oct 2018 0:00:00          | 31 May 2019 23:59:59         | reject by default | 3                 |
      | 1 Jun 2019 0:00:00          | 15 Sept 2019 23:59:59        | reject by default | 1                 |
    When an application is submitted at "<submission time>"
    Then the application's RBD time is "<RBD time>"

    Examples:
      | submission time                 | RBD time                       | notes                          |
      | Mon 20 May 2019 9:00:00 AM BST  | Fri 24 May 2019 0:00:00 AM BST | submitted in timeframe 1       |
      | Mon 3 June 2019 9:00:00 AM BST  | Wed 5 June 2019 0:00:00 AM BST | submitted in timeframe 2       |
      | Fri 31 May 2019 9:00:00 AM BST  | Thu 6 June 2019 0:00:00 AM BST | across the boundary            |

  Scenario Outline: applications that without offers are rejected automatically when their RBD time has elapsed
    Given an application in "<application state>" state
    And its RBD time is set to "<RBD time>"
    When the automatic process for rejecting applications is run at "<current time>"
    Then the new application state is "<new application state>"

    Examples:
      | application state  | RBD time             | current time         | new application state |
      | references pending | 23 May 2019 11:59:59 | 24 May 2019 00:00:00 | rejected              |
      | references pending | 23 May 2019 11:59:59 | 23 May 2019 11:59:58 | references pending    |
