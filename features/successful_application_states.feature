Feature: successful application states
  Background:
    Given the following rules around “reject by default” decision timeframes:
      | application submitted after | application submitted before | # of working days until rejection |
      | 1 Oct 2018 0:00:00          | 15 Sept 2025 23:59:59        | 3                                 |

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
