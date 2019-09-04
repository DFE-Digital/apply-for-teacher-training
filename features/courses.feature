@candidate
Feature: same & different courses

  Candidates shouldn't be able to apply to the same course multiple times.

  Scenario Outline: same & different courses
    Then <course A> and <course B> are treated as the same choice: <same?>

  Examples:
    | course A           | course B           | same? | notes                                 |
    | U80/X100 (site: A) | S13/372B (site: A) | N     | Different providers                   |
    | U80/X100 (site: A) | U80/X100 (site: B) | Y     | Same course but different sites       |
    | U80/X100 (site: A) | U80/A123 (site: A) | N     | Same provider, different course       |
    | S13/X100 (site: A) | U80/X100 (site: A) | N     | Different providers, same course code |
