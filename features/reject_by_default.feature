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

  Scenario Outline: the 'reject by default' (RBD) date on an application
    Given the following rules around “reject by default” decision timeframes:
      | application submitted after | application submitted before | # of working days until rejection |
      | 1 Oct 2018 0:00:00          | 15 Sept 2019 23:59:59        | 3                                 |
    And there are no holidays
    When an application is submitted at "<submission time>"
    Then the application's RBD time is "<RBD time>"

    Examples:
      | submission time                 | RBD time                                  | notes                          |
      | Mon 2 Sept 2019 9:00:00 AM BST  | Thu 5 Sept 2019 11:59:59.999999999 PM BST | app submitted during work time |
      | Mon 2 Sept 2019 11:00:00 PM BST | Thu 5 Sept 2019 11:59:59.999999999 PM BST | app submitted out of hours     |
      | Mon 4 Feb 2019 11:00:00 PM GMT  | Thu 7 Feb 2019 11:59:59.999999999 PM GMT  | submissions in GMT             |
