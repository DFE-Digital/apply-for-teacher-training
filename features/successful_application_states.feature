Feature: successful application states

  Scenario Outline: A successful application changes state depending on candidate, referee and provider actions.
    Given an application in "<original state>" state
    When a <actor> <action>
    Then the new application state is "<new state>"

    Examples:
      | original state       | actor    | action           | new state            |
      | references pending   | referee  | submit reference | application complete |
      | application complete | provider | set conditions   | offer made           |
