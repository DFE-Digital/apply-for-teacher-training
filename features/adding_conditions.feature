@provider
Feature: adding conditions – who can add them and when

  Providers can add conditions to an application as part of making the offer,
  or when the application has the 'offer made' status. Both the accredited body
  and the non-accredited body can add conditions.

  Conditions can be both academic and non-academic. For example, if a candidate
  still needs to sit exams in order to obtain necessary qualifications or
  undergo the required criminal record checks to provide evidence of suitability
  to teach. The provider isn't allowed to make a successful interview a condition
  (i.e. an interview should happen before and offer is made, not after).

  Background:
    Given the following providers:
      | provider code | is an accredited body? |
      | 10M           | N                      |
      | U80           | Y                      |
      | S13           | Y                      |
    And the following courses:
      | course code | provider code | accredited body |
      | X123        | 10M           | U80             |

  Scenario Outline: the provider and the accredited body can add conditions after an offer has been made
    When an application has been made to a course X123
    And the application in "<Application status>" state
    Then a provider with a "<Provider code>" is able to add conditions: "<Can add conditions?>"

    Examples:
      | Provider code | Application status   | Can add conditions? | Notes                           |
      | 10M           | application complete | N                   | Application in the wrong status |
      | U80           | meeting conditions   | N                   | Application in the wrong status |
      | S13           | offer made           | N                   | Wrong provider                  |
      | U80           | offer made           | Y                   |                                 |
      | 10M           | offer made           | Y                   |                                 |
