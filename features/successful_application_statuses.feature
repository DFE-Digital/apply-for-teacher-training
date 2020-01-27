@candidate @provider
Feature: successful application statuses

  Scenario Outline: A successful application changes status depending on candidate, referee and provider actions.
    Given an application choice has "<original status>" status
    When the <actor> takes action "<action>"
    Then the new application choice status is "<new status>"

    Examples:
      | original status            | actor     | action                 | new status                 |
      | unsubmitted                | candidate | submit                 | awaiting references        |
      | awaiting references        | candidate | references complete    | application complete       |
      | application complete       | candidate | withdraw               | withdrawn                  |
      | application complete       | candidate | send to provider       | awaiting provider decision |
      | awaiting provider decision | provider  | make offer             | offer                      |
      | awaiting provider decision | provider  | reject                 | rejected                   |
      | awaiting provider decision | candidate | withdraw               | withdrawn                  |
      | offer                      | candidate | accept                 | pending conditions         |
      | offer                      | candidate | decline                | declined                   |
      | offer                      | provider  | make offer             | offer                      |
      | offer                      | provider  | reject                 | rejected                   |
      | rejected                   | provider  | make offer             | offer                      |
      | pending conditions         | provider  | confirm conditions met | recruited                  |
      | pending conditions         | candidate | withdraw               | withdrawn                  |
      | recruited                  | provider  | confirm enrolment      | enrolled                   |
      | recruited                  | candidate | withdraw               | withdrawn                  |
