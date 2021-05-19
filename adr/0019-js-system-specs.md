# 19. JavaScript System Specs

Date: 2021-05-19

## Status

Accepted

## Context

As we add more JavaScript to the service as progressive enhancements, we need to ensure it is fully tested and protected against regressions.
In the past, we have explored running JavaScript in system specs but ran into issues with CI containers not being able to install and run chromedriver.

## Proposition

Capybara supports running system specs with a driver different to the default.
It comes with a JS-ready driver `selenium_chrome_headless`.
This driver does not work in Docker though (see: https://stackoverflow.com/questions/50610316/capybara-headless-chrome-in-docker-returns-devtoolsactiveport-file-doesnt-exist), so we have to set up our own Selenium webdriver that is compatible.

We could start using this driver, and run JS code in system specs.

### Pros

- We can test the integration of JS and Rails code

### Cons

- Slows down our CI - installing extra dependencies and starting a browser for certain system specs

## Decision

Previously, we tested JS in an isolated way either in a unit test, or a test on a dummy HTML page.
This missed out testing the interplay between JS and Rails-generated HTML, which is the most important part of the feature.

Installing Chrome and chromedriver in CI test runners does not take long, and it can potentially be made more efficient by GitHub actions caching.
The slowdown from running tests using the chrome headless driver only applies to tests specifying `js: true`.

Therefore, we have decided to introduce JS enabled system tests, which can be used sparingly to test the integration of JS features.

## Consequences

- Chrome and chromedriver are now required to run the full test suite locally
- System specs with `js: true` run in a headless chrome browser where any JavaScript for the page is able to run
- JavaScript system specs run on CI
