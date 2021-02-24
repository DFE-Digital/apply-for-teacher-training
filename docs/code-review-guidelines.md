# Code review guidelines

## Background

We use pull requests (PRs) for all code changes. All PRs have to be
reviewed and approved by at least one other developer before being merged into
`master`.

The main objective of code reviews is to improve the quality of code that
reaches production, so that our codebase is maintainable and correct. We want
to reduce the number of bugs that go live though there are other secondary
benefits like knowledge sharing.

## Guidelines

### Preparing PRs

- Create a draft PR if you want early feedback for work in progress.
- We have a template for the PR descriptions. The _Guidance to
  review_ section should contain any information that a reviewer might find
  helpful. In particular consider adding:
  - A list of particular questions that you would like feedback on, e.g. design
    choices.
  - Step-by-step instructions on how to manually test the change, whether
    running locally or using a review app.
- Consider extending test application data if it would make the PR easier to test.
- If a PR is going to be complex to review, affects core functionality, touches
  on application security or is deemed to be risky for some other reason tag
  it as requiring two approvals rather than the normal one.
- Follow general best practice for raising PR e.g. [How to raise a good pull request](https://www.annashipman.co.uk/jfdi/good-pull-requests.html).
  - Aim for each commit to be atomic, introducing a non-breaking change with all tests and linter passing. Consider arranging your commits into appropriate logical chunks with [git's history rewriting features](https://git-scm.com/book/en/v2/Git-Tools-Rewriting-History). This can make the PR easier to review and revert.
  - Try to avoid merge commits and use `git rebase master` instead.
### Reviewing PRs

- Anybody can review a PR. Code reviews from a different team are encouraged as
  well as those from people more familiar with the code being changed. Everyone
  should get involved in code reviews, regardless of experience levels or role.
- Consider asking for a ‘guided tour’ of a PR if a quick call with the author
  is helpful.
- It's recommended, wherever practical, to manually test the change either by
  running the code locally or using the review app.
- If as a reviewer you have any concerns about being the only reviewer you
  should tag the PR as requiring two approvals so that at least one other
  person checks it.
