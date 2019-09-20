@candidate
Feature: Declining offers
  Candidates decline offers when:
  - they have chosen another offer over the one in question
  - they don't want to accept any of the offers they have received

  Scenario Outline: A candidate can decline an application with an offer
    Given an application in "<original state>" state
    When the <actor> takes action "<action>"
    Then the new application state is "<new state>"

    Examples:
      | original state      | actor     | action        | new state |
      | unconditional offer | candidate | decline offer | declined  |
      | conditional offer   | candidate | decline offer | declined  |
