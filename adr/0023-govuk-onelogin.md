# 22. GOV.UK One Login Integration

**Date:** 05/06/2024

## Status:

Proposed/Spike

## Context
(How GOV.UK One Login works)[https://docs.sign-in.service.gov.uk/how-gov-uk-one-login-works/#how-gov-uk-one-login-works]

We will only need P0 Authentication for now. This does not prove identity but provides Authentication to a similar level as what “magic links“ do for us currently. The idea is Candidates can login using the One Login service rather than using a clunky magic links for signing into the service

At DfE there has been a push to use GOV.UK One Login to manage user authentication for all DfE applications, this has a few benefits:
- Creates consistency across all DfE owned applications
- Allows a user to sign in using GOV.UK One Login once and access all GOV.UK One Login supported DfE applications
- Is more secure as we have one system to manage authentication

## Proposition:
To implement GOV.UK One Login for candidate authentication only. This involves signing up the service to (GOV.UK One Login)[https://www.sign-in.service.gov.uk/getting-started] (Will need to request production use when ready). Once signed up the configuration can be managed within the (GOV.UK One Login admin tool)[https://admin.sign-in.service.gov.uk/sign-in/enter-email-address]. Using the (GOV.UK One Login technical documentation)[https://docs.sign-in.service.gov.uk/] we can then setup our application to communicate with GOV.UK One Login and manage the callbacks accordingly.

## Consequences:
- Unsure how users will react to the change in sign up and sign in flow
- Adding another dependency to the service, if GOV.UK One Login goes down can users authenticate? (probably not)
- Migrating users to GOV.UK One Login. (The approach we have so far is to just make them create an account when first using the service with GOV.UK One Login implemented)
