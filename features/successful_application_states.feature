Feature: successful application states

  Scenario Outline: A successful application changes state depending on candidate, referee and provider actions.
    Given an application in "<original state>" state
    When a <actor> <action>
    Then the new application state is "<new state>"

    Examples:
      | original state       | actor     | action                 | new state            |
      | unsubmitted          | candidate | submit                 | references pending   |
      | references pending   | referee   | submit reference       | application complete |
      | application complete | provider  | set conditions         | offer made           |
      | offer made           | candidate | accept offer           | meeting conditions   |
      | meeting conditions   | provider  | confirm conditions met | recruited            |
      | recruited            | provider  | confirm onboarding     | enrolled             |
