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
      | provider code | provider training locations |
      | P1            | A, B                        |
      | P2            | A, B                        |
      | P3            | A, B                        |
      | P4            | A, B                        |
      | P5            | A, B                        |
    And the following courses:
      | provider code | course code | course training locations | open? |
      | P1            | C1          | A, B                      | Y     |
      | P2            | C2          | A, B                      | Y     |
      | P3            | C3          | A, B                      | Y     |
      | P4            | C4          | A, B                      | Y     |
      | P5            | C5          | A, B                      | N     |

  Scenario Outline: applications at Apply 1
    At Apply 1, a candidate can submit concurrent applications to distinct, open courses up to the limit. In this spec,
    the limit has been configured to be 3.

    Given a candidate with no submitted application forms in the current recruitment cycle
    When the candidate creates a new application form on 31 July 2019
    Then the most recent application form is at stage Apply 1
    And the candidate's application to courses <courses> at <submission time> is <valid or not?>

  Examples:
    | courses                    | submission time | valid or not? | notes                         |
    | P1/C1                      | 1 Aug 2019      | valid         | 1 course                      |
    | P1/C1, P2/C2               | 1 Aug 2019      | valid         | 2 courses                     |
    | P1/C1, P2/C2, P3/C3        | 1 Aug 2019      | valid         | 3 courses                     |
    |                            | 1 Aug 2019      | invalid       | not enough courses            |
    | P1/C1, P2/C2, P3/C3, P4/C4 | 1 Aug 2019      | invalid       | too many courses              |
    | P1/C1, P2/C2, P3/C3        | 8 Sept 2019     | invalid       | too late - Apply 1 has closed |
    | P5/C5                      | 1 Aug 2019      | invalid       | the course is not open        |

  Scenario: Apply 2 comes after Apply 1
    Given the candidate has submitted application forms with the following choices:
      | P1/C1, P2/C2, P3/C3 |
    When the candidate creates a new application form on 31 July 2019
    Then the most recent application form is at stage Apply 2

  Scenario: Apply 2 repeats after Apply 2
    Given the candidate has submitted application forms with the following choices:
      | P1/C1, P2/C2, P3/C3 |
      | P4/C4               |
      | P5/C5               |
    When the candidate creates a new application form on 31 July 2019
    Then the most recent application form is at stage Apply 2
