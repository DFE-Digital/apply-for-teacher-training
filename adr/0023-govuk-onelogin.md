# 22. GOV.UK One Login Integration

**Date:** 05/06/2024

## Status:

Proposed/Spike

## Context
[How GOV.UK One Login works](https://docs.sign-in.service.gov.uk/how-gov-uk-one-login-works/#how-gov-uk-one-login-works)

We will only need P0 Authentication for now. This does not prove identity but provides Authentication to a similar level as what “magic links“ do for us currently. The idea is Candidates can login using the One Login service rather than using a clunky magic links for signing into the service

At DfE there has been a push to use GOV.UK One Login to manage user authentication for all DfE applications, this has a few benefits:
- Creates consistency across all DfE owned applications
- Allows a user to sign in using GOV.UK One Login once and access all GOV.UK One Login supported DfE applications
- Is more secure as we have one system to manage authentication

## Roll Out Plan:
There shouldn't be much changes needed from our end as we have silently integrated with GOV.UK One Login. If a user already has an account they just need to sign up with the same email with GOV.UK One Login, we then just associate that GOV.UK One Login user to the user in our database. If its a brand new account that we don't have in our databse already then when they create their GOV.UK One Login account and sign in using that account we create a new user in our database.

I think the question is potentially how we let the users know of the new sign in/ sign up flow. As it may confuse them at first. Maybe comms need to be sent to all current users, to make them aware of the change and that if they already are using the Apply service to make sure to sign up to GOV.UK One Login with that same email address.

## Proposition:
To implement GOV.UK One Login for candidate authentication only. This involves signing up the service to [GOV.UK One Login](https://www.sign-in.service.gov.uk/getting-started) (Will need to request production use when ready). Once signed up the configuration can be managed within the [GOV.UK One Login admin tool](https://admin.sign-in.service.gov.uk/sign-in/enter-email-address). Using the [GOV.UK One Login technical documentation](https://docs.sign-in.service.gov.uk/) we can then setup our application to communicate with GOV.UK One Login and manage the callbacks accordingly.

## Consequences:
- Unsure how users will react to the change in sign up and sign in flow
- Adding another dependency to the service, if GOV.UK One Login goes down can users authenticate? (probably not)
- Migrating users to GOV.UK One Login. (The approach we have so far is to just make them create an account when first using the service with GOV.UK One Login implemented)
