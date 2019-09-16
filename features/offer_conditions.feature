@provider
Feature: Managing conditions on offers
  Teacher training offers often include conditions that the applicant must fulfil
  before they can take their place on the course.

  Conditions can be both academic and non-academic. For example, if a candidate
  still needs to sit exams in order to obtain necessary qualifications or
  undergo the required criminal record checks to provide evidence of suitability
  to teach. The provider isn't allowed to make a successful interview a condition
  (i.e. an interview should happen before an offer is made, not after).

  Who can manage conditions
  =========================

  Accredited bodies are a subset of providers, who have been accredited by the
  Department for Education; they are the only ones who can recommend trainees
  for qualified teacher status. If a provider  hasn't been accredited by DfE,
  they will partner with another provider that has,  and will manage courses
  and applications together. For a given course, both the provider of the course
  and the course's accredited body is able to manage conditions.

  Background:
    Given the following providers:
      | provider code | is an accredited body? |
      | 10M           | N                      |
      | U80           | Y                      |
      | S13           | Y                      |
    And the following courses:
      | course code | provider code | accredited body |
      | X123        | 10M           | U80             |

  Scenario Outline: adding conditions - who can do it and when
    Providers can add conditions to an application as part of making the offer,
    or when the application has the 'conditional offer' status. Both the accredited body
    and the non-accredited body can add conditions.

    When an application has been made to a course X123
    And the application in "<Application status>" state
    Then a provider with code "<Provider code>" is able to add conditions: "<Can add conditions?>"

    Examples:
      | Provider code | Application status   | Can add conditions? | Notes                           |
      | 10M           | application complete | N                   | Application in the wrong status |
      | U80           | meeting conditions   | N                   | Application in the wrong status |
      | U80           | unconditional offer  | N                   | Application in the wrong status |
      | S13           | conditional offer    | N                   | Wrong provider                  |
      | U80           | conditional offer    | Y                   |                                 |
      | 10M           | conditional offer    | Y                   |                                 |

  Scenario Outline: amending conditions - who can do it and when
    Once a provider makes a conditional offer, they can amend these conditions,
    but only if the candidate has not accepted their offer.

    Given an application has been made to a course X123
    And the application in "<Application status>" state
    Then a provider with code "<provider code>" is able to amend conditions: "<Can amend conditions?>"

    Examples:
      | provider code | Application status   | Can amend conditions? | Notes                           |
      | 10M           | application complete | N                     | Application in the wrong status |
      | U80           | meeting conditions   | N                     | Application in the wrong status |
      | U80           | unconditional offer  | N                     | Application in the wrong status |
      | S13           | conditional offer    | N                     | Wrong provider                  |
      | U80           | conditional offer    | Y                     |                                 |
      | 10M           | conditional offer    | Y                     |                                 |

  Scenario: amending condition changes the offer's expiry time
    The expiry time on the offer is reset when conditions are successfully amended.

    Given an application has been made to a course X123
    And the application in "conditional offer" state
    And the expiry time on the offer is "12 June 2019 12:00:00 PM"
    When the provider with code "U80" amends a condition at 8:00 AM on 13 June 2019
    And the new expiry time on the offer is "<expected DBD time>"
