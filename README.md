[![Build Status](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_apis/build/status/Apply/apply-for-postgraduate-teacher-training?branchName=master)](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_build/latest?definitionId=49&branchName=master)

# Apply for postgraduate teacher training

This service enables postgraduate candidates to apply for initial teacher
training.

## Prerequisites

- Ruby 2.6.3
- NodeJS 8.11.x
- Yarn 1.12.x

## Setting up the app in development

1. Run `yarn` to install node dependencies
2. Run `bundle install` to install the gem dependencies
3. Run `rails s` to launch the app on https://localhost:3000

## Running the tests and linters

To run the specs you must provide a path to chromedriver, which is the headless
browser we use to interact with JavaScript.

```
CHROMEDRIVER_PATH=/path/to/chromedriver bundle exec rake
```

If you do not have chromedriver installed, first execute
`bin/install-chromedriver`, which will install it for you and report the path.
