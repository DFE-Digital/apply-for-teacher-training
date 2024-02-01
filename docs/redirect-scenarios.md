# Sign in feature / redirects

## Scenario 1: Unsuccessful 2023 application

Sign in for 2023 applications.

Sign in for different statuses of applications:

These states:

* 'cancelled'
* 'rejected'
* 'application_not_sent'
* 'offer_withdrawn'
* 'declined'
* 'withdrawn'
* 'conditions_not_met'

Expectation: redirects to the /complete action and shows content in the
page that asks to carry over their application ("Apply again" button).

## Scenario 2: Successfull 2023 application

These states:

*  'pending_conditions'
*  'recruited'

Expectation: redirects to the post offer dashboard. That's it

## Scenario 3: 2023 application with Offer deferred

* offer_deferred: 'offer_deferred'

Expectation: My understanding is that we should render '/complete' but without
carry over info?

## Scenario 4: 2024 application (with incomplete sections and unsubmitted)

Expectation: Sign in and redirect to your details tab

## Scenario 5: 2024 application (with complete sections and submitted)

Expectation: Sign in and redirect to your applications tab

## Scenario 6: 2024 application already login tries to access '/'

Steps:

1. Sign in
2. Visit '/'

Expectation: Redirect to your details or your applications tab (see scenario 4
or 5)

## Scenario 7: 2023 application already login tries to access '/'

Steps:

1. Sign in
2. Visit '/'

Expectation: Redirect to /complete with carry over message (see scenario 1)

## Scenario 8: 2023 application without anything

Have 1 application without anything basically (no application choice and
unsubmitted) then `Sign in`.

Expectation: Redirect to /start-carry-over with carry over message and a button
to carry over ("Continue")

# Trying to cheat the game!

## Scenario 9: 2023 apps shouldn't try to access 2024 routes

The scenario is when you sign in as 2023 in the /complete route (whenever
application choice states that be!) you shouldn't have access to 2024 routes.

Try the best to cheat the system here.

## Scenario 10: 2024 apps shouldn't try to access routes like /complete

The scenario is when you sign in as 2024 and try to access the /complete route (whenever
application choice states that be!) you shouldn't have access to /complete
because if is available you can cheat the game by creating another application
form that can continuously apply until it reaches the limit.

Try the best to cheat the system here so you can by pass the 2024 continuous app
limit here.

# Carry over

## Scenario 11: Carry over 2023 unsuccessfull applications

Find an unsuccessfull application from 2023 and carry over

One of these states:

* 'cancelled'
* 'rejected'
* 'application_not_sent'
* 'offer_withdrawn'
* 'declined'
* 'withdrawn'
* 'conditions_not_met'

## Scenario 12: Carry over 2023 unsubmitted applications

* Have 1 application without anything basically (no application choice and
unsubmitted) then `Sign in`.
* This should redirect to /start-carry-over with carry over message and a button
to carry over ("Continue")
* Click 'continue' (to carry over)

Expectation: Be on 2024 recruitment cycle (see your details tab, your
applications tab etc)

# Questions or scenarios that we might need to test?

* Do we have more scenarios? (Add a course from find?)
