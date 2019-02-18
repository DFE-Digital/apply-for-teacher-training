# Apply for postgraduate teacher training

**Apply for postgraduate teacher training** service for candidates to apply to intitial teacher training courses.

Ruby on Rails application has been set up with:

* RSpec
* Cucumber
* SimpleCov
* `pg` driver for PostgreSQL
* Devise for user authentication - on `Candidate` model for candidates and `Admin` model for team admins
* [AASM](https://github.com/aasm/aasm) for state machine and transitions

Admin pages can be accessed at `/admin` - test account: `example@example.com`, password `testing123`

Uses [GOV.UK Design System](https://design-system.service.gov.uk/). Run `yarn` to pull in necessary packages.
