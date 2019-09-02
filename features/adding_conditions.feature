Feature: adding conditions – who can add them and when

  Providers can add conditions to an application as part of making the offer,
  or when the application has the 'offer made' status. Both the accredited body
  and the non-accredited body can add conditions. The provider isn't allowed to
  make a successful interview a condition (i.e. an interview should happen before
  and offer is made, not after).

  Background:
    Given the following providers:
      | provider code | is an accredited body? |
      | 10M           | N                      |
      | U80           | Y                      |
      | S13           | Y                      |
    And the following courses:
      | course code | provider | accredited body |
      | X123        | 10M      | U80             |

  Scenario Outline: adding conditions – who can add them and when
    When an application has been made to a course X123
    And the application in "<application status>" state
    Then an "<Actor>" is able to add conditions: "<Can add conditions?>"

    Examples:
      | Actor          | Application status   | Can add conditions? | Notes                           |
      | Candidate      | -                    | N                   | Not a provider                  |
      | Provider (1OM) | application complete | N                   | Application in the wrong status |
      | Provider (S13) | offer made           | N                   | Wrong provider                  |
      | Provider (U80) | offer made           | Y                   |                                 |
      | Provider (1OM) | offer made           | Y                   |                                 |
