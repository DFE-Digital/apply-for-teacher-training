[![Build Status](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_apis/build/status/Apply/apply-for-postgraduate-teacher-training?branchName=vsts_build_and_deploy)](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_build/latest?definitionId=49&branchName=master)

# Apply for postgraduate teacher training

**Apply for postgraduate teacher training** service for candidates to apply to intitial teacher training courses.

Ruby on Rails application has been set up with:

* Ruby 2.6.1
* RSpec
* Cucumber
* SimpleCov
* `pg` driver for PostgreSQL
* Devise for user authentication - on `Candidate` model for candidates and `Admin` model for team admins
* [AASM](https://github.com/aasm/aasm) for state machine and transitions

Admin pages can be accessed at `/admin` - test account: `example@example.com`, password `testing123`

Uses [GOV.UK Design System](https://design-system.service.gov.uk/). Run `yarn` to pull in necessary packages.

### Using Guard

Guard can automatically run tests when files change. To take advantage of this,
run:

```
bundle exec guard
```

## Linting

It's best to lint just your app directories and not those belonging to the framework, e.g.

```
bundle exec govuk-lint-ruby app config db lib spec --format clang
```
