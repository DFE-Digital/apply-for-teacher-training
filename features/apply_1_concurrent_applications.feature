Feature: Apply 1 - 3 concurrent applications

  At Apply 1, candidates can submit up to 3 applications simultaneously. The
  applications have to be to different courses (refer to the courses feature
  to see the definitions of course equality). Candidates cannot add more
  applications at Apply 1 once they've submitted some already.

  Scenario Outline: submitting applications at Apply 1
    Given the candidate has already submitted <applications already submitted> applications at Apply 1
    Then they can submit more Apply 1 applications: <can submit new applications?>

  Examples:
    | applications already submitted | can submit new applications? |
    | 0                              | Y                            |
    | 1                              | N                            |
    | 2                              | N                            |
    | 3                              | N                            |
