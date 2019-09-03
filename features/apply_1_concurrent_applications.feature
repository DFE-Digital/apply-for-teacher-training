Feature: Apply 1

  At Apply 1, candidates can submit up to 3 applications simultaneously. The
  applications have to be to different courses (refer to the courses feature
  to see the definitions of course equality). Candidates cannot add more
  applications at Apply 1 once they've submitted some already.

  Scenario Outline: up to 3 applications simultaneously
    Given the application stages are set up as follows:
      | name    | simultaneous applications limit |
      | Apply 1 | 3                               |
    When the candidate tries to submit applications to <number of distinct courses> different courses
    Then their submission succeeds: <success or not?>

  Examples:
    | number of distinct courses | success or not? |
    | 0                          | N               |
    | 1                          | Y               |
    | 2                          | Y               |
    | 3                          | Y               |
    | 4                          | N               |

  Scenario Outline: submitting applications at Apply 1
    Given the candidate has already submitted <applications already submitted> applications at Apply 1
    Then they can submit more Apply 1 applications: <can submit new applications?>

  Examples:
    | applications already submitted | can submit new applications? |
    | 0                              | Y                            |
    | 1                              | N                            |
    | 2                              | N                            |
    | 3                              | N                            |
