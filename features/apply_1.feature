@candidate
Feature: Apply 1

  At Apply 1, candidates can submit up to 3 applications simultaneously. The
  applications have to be to different courses (refer to the courses feature
  to see the definitions of course equality). Candidates cannot add more
  applications at Apply 1 once they've submitted some already. A course has to be
  open to accept applications.

  Background:
    Given the application stages are set up as follows:
      | type    | simultaneous applications limit | start time | end time    |
      | Apply 1 | 3                               | 1 Oct 2018 | 6 Sept 2019 |
    And the following providers:
      | provider code |
      | P1            |
      | P2            |
      | P3            |
      | P4            |
      | P5            |
    And the following courses:
      | provider code | course code | open? |
      | P1            | C1          | Y     |
      | P2            | C2          | Y     |
      | P3            | C3          | Y     |
      | P4            | C4          | Y     |
      | P5            | C5          | N     |

  Scenario Outline: at Apply 1, a candidate can submit up to 3 applications simultaneously to distinct, open courses
    Given the candidate has made no Apply 1 applications in the current recruitment cycle
    Then the candidate's submission of Apply 1 applications to courses <courses> at <submission time> is <valid or not?>

  Examples:
    | courses                    | submission time | valid or not? | notes                         |
    | P1/C1                      | 1 Aug 2019      | valid         | 1 course                      |
    | P1/C1, P2/C2               | 1 Aug 2019      | valid         | 2 courses                     |
    | P1/C1, P2/C2, P3/C3        | 1 Aug 2019      | valid         | 3 courses                     |
    |                            | 1 Aug 2019      | invalid       | not enough courses            |
    | P1/C1, P2/C2, P3/C3, P4/C4 | 1 Aug 2019      | invalid       | too many courses              |
    | P1/C1, P2/C2, P3/C3        | 8 Sept 2019     | invalid       | too late - Apply 1 has closed |
    | P5/C5                      | 1 Aug 2019      | invalid       | the course is not open        |

  Scenario Outline: a candidate can only make one Apply 1 batch submission per recruitment cycle
    Given the candidate has made <# of previous applications> Apply 1 applications in the current recruitment cycle
    Then the candidate's submission of Apply 1 applications to course P1/C1 at 12:00 PM, 1 Aug 2019 is invalid

  Examples:
    | # of previous applications |
    | 1                          |
    | 3                          |
