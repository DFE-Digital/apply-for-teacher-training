# 20. Strict time control in test suite

Date: 2022-10-20

## Status

Proposed

## Context

There are a number of tests (and some sections of code) which make one or more of the following assumptions:

- Time will move perceptibly between statements
- Time will NOT move perceptibly between statements
- Records can be sorted in creation-order using only the `created_at` timestamp
- Tests written today will pass on any given day of the year
- Using Timecop in specific test setups is enough to control time throughout the stack

Some of these assumptions are in opposition to one another, and none of them are universally true, which leads to flakey and/or "timebomb" tests.

## Proposition

To restore order we must strictly control the application clock in our test suite.  This means that we cannot allow the clock to run freely, and must robustly reset the time to a known value before and after each test.  We should also freeze time by default and only move time consciously as needed.

We/I have created a Timecop wrapper called `TestSuiteTimeMachine` which provides a slightly higher-level API for controlling time in tests.

### API guidance

- `.pretend_it_is(datetime)` should be used once at the start of the test suite, as soon as possible in the test setup.  This sets the baseline for the whole test suite to run against.
- `.travel_permanently_to(datetime)` should be used to set the time at the start of a test if needed.  It will not affect other tests, but should only be used once per test.
- `.travel_temporarily_to(datetime)` should be used to temporarily travel in time within a test.  It will not affect other tests, and should be used as many times as needed within a test.  This should most commonly used to temporarily move back in time to do some specific test setup.
- `.advance_time_to/advance_time_by(duration)` should be used to move time forward within a test.  It will not affect other tests, and should be used as many times as needed within a test.  This will mostly be used to jump forward to specific points in time to test the behaviour of the system at that point.
- `.advance` moves time forward by one second.  It can be used as many times as needed within a test and will most commonly be used to ensure that e.g. `created_at` timestamps increment as expected during a series of record creations.
- `.reset` should be used to reset the time to the baseline at the end of a test.  This should be handled for you under most circumstances.
- `.unfreeze!` allows the clock to move forward naturally from the current time.  This should be used sparingly, and only when the test is specifically testing the behaviour of the system as time passes.
- `.revert_to_real_world_time` unstubs time entirely and allows the system clock to move naturally.  This should be used very infrequently, if ever.

### Pros

- We can be confident that tests will pass on any given day of the year
- We're provided with a more natural way of moving time forward to key points as the test progresses
- We will reveal any code which is unwittingly dependent on e.g. the precision of timestamps and/or at risk of race conditions
- We can externally control the presumed time of the test suite, which will allow us to run the test suite against multiple important dates and deadlines, as well as sweep ahead for time-sensitive tests by running the suite at some rolling period in the future
- We remove a coupling with `Timecop`

### Cons

- We will need to update a lot of tests to use the new API
- We replace the `Timecop` coupling with a new (less coupled) coupling on our own `TestSuiteTimeMachine` wrapper, which may itself be extracted to a gem in the future
- We will have to think more carefully about the effects of time on our tests as we write them
- We will need to write code which makes no assumptions about the passage of time in relation to e.g. the creation of records
