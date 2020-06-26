# Lessons learned

- When sending a one-off email, do a dry run and think about how to make sure that you're sending them to the right people. (See [incident on 2020-06-05](https://trello.com/c/6EhE0oSo/287-2020-06-05-apply-again-email-being-sent-to-wrong-candidates))
- When adding new fields to the database, if you're storing "yes/no" values from checkboxes in forms, always use the `boolean` type in the database. Do not overload a string with "yes/no/other values"; use multiple fields if that's necessary. (See [near miss about incorrect safeguarding declaration being displayed to the provider](https://trello.com/c/PAybbGv3/216-incorrect-safeguarding-concerns-from-referee-safeguarding-declaration-from-candidate-was-displayed-to-the-provider))
