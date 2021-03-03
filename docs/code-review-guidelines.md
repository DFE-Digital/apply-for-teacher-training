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
- We strongly recommend extending test application data if it would make the PR
  easier to test. We rely on test data to provide a solid test platform so it
  should aim to replicate the features of production data as possible.
- If a PR is going to be complex to review, affects core functionality, touches
  on application security or is deemed to be risky for some other reason tag
  it as requiring two approvals rather than the normal one.
- Follow general best practice for raising PR e.g. [How to raise a good pull request](https://www.annashipman.co.uk/jfdi/good-pull-requests.html).
  - Aim for each commit to be atomic, introducing a non-breaking change with all tests and linter passing. Consider arranging your commits into appropriate logical chunks with [git's history rewriting features](https://git-scm.com/book/en/v2/Git-Tools-Rewriting-History). This can make the PR easier to review and revert.
  - Try to avoid merge commits and use `git rebase master` instead.

### Reviewing PRs

#### Process

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
- Use positive language and be humble in review comments. Nits are OK but flag
  them as such.

#### Checklist

These are some of the things that as a reviewer you may wish to check:

- [ ] Are tests sufficient and robust? It is reasonable to ask for more tests.
- [ ] Does the change make the code harder to understand/maintain?
- [ ] Should the change be behind a feature flag? If it is behind a feature flag
  is it watertight?
- [ ] Does the change break backward compatibility?
- [ ] Does the code introduce any security vulnerabilities? (e.g. are queries
  scoped to the current user?)
- [ ] Have migrations been tested? Do they follow zero downtime patterns? (e.g.
  migrations are deployed before code that depends on them).
- [ ] Is the change consistent with established conventions? (e.g. use of
  components, test style etc.)
- [ ] Should documentation be updated as a result of this change? (Including
  developer/support docs as well as API docs).
