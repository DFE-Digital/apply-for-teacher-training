@candidate
Feature: same & different course choices

  Candidates shouldn't be able to apply to the same course multiple times.

  # TODO: are choices to same provider/same course/different accredited body
  # the same or different?

  Background:
    Given the following providers:
      | provider code | provider training locations |
      | U80           | A, B                        |
      | S13           | A                           |
    And the following courses:
      | provider code | course code | course training locations |
      | U80           | X100        | A, B                      |

  Scenario Outline: same & different courses
    Then <course choice A> and <course choice B> are treated as the same choice: <same?>

  Examples:
    | course choice A        | course choice B        | same? | notes                                        |
    | U80/X100 (location: A) | S13/372B (location: A) | N     | Different providers                          |
    | U80/X100 (location: A) | U80/X100 (location: B) | Y     | Same course but different training locations |
    | U80/X100 (location: A) | U80/A123 (location: A) | N     | Same provider, different course              |
    | S13/X100 (location: A) | U80/X100 (location: A) | N     | Different providers, same course code        |
