Feature: working days

  "Reject by default" periods are calculated using working days. Working days exclude:

  - weekends
  - bank and public holidays

  Scenario: Working days exclude weekends
    Then working days are defined as follows:
      | Date        | Day of the week? | Working day? |
      | 7 Jan 2019  | Monday           | Y            |
      | 8 Jan 2019  | Tuesday          | Y            |
      | 9 Jan 2019  | Wednesday        | Y            |
      | 10 Jan 2019 | Thursday         | Y            |
      | 11 Jan 2019 | Friday           | Y            |
      | 12 Jan 2019 | Saturday         | N            |
      | 13 Jan 2019 | Sunday           | N            |
