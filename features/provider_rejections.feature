@provider
Feature: rejections by the provider

  Scenario Outline: A provider can reject applications at various stages
    Given an application in "<original state>" state
    When a <actor> <action>
    Then the new application state is "<new state>"

    Examples:
      | original state       | actor    | action  | new state | possible reason                  |
      | references pending   | provider | reject  | rejected  | failed the sift                  |
      | application complete | provider | reject  | rejected  | failed the sift/failed interview |
      | offer made           | provider | reject  | rejected  | course is full                   |
      | meeting conditions   | provider | reject  | rejected  | if conditions not met in time    |
      | recruited            | provider | reject  | recruited | not possible                     |
