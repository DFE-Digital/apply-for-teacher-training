# 2. Use Devise for authentication

Date: 2019-08-22

## Status

Accepted

## Context

Following user research on the prototype of the candidate-facing
application form, the design team decided to offer a Magic Link
instead of a traditional username/password account creation flow.

https://docs.google.com/presentation/d/1_pYQl4oX0-7boqy5D6IqhkoI3QvZjlYrf1qfLZkHfn0/edit#slide=id.g5f07c7bcc5_1_0

The technical team carried out two spikes around this functionality
and discussed their findings with other teams.

The spikes covered

- a gem called `passwordless` which offers the Magic Link feature out
  of the box
- customising the popular authentication library `devise` to accept a
  Magic Link instead of a username and password combination

`passwordless` offered a turnkey solution which was well-matched to
the problem. It is a small single-maintainer project without wide
adoption: this is harder to feel confident about.

`devise` is a very popular battle-tested library, which gave us some
confidence that its authentication system would be sound . However,
the implementation of Magic Links on top of that required some
knowledge of how this slightly esoteric gem works.

http://blog.plataformatec.com.br/2019/01/custom-authentication-methods-with-devise/

Following a meeting with peers the team also considered a DIY approach
following the example of the School Experience Prototype team.

https://github.com/DFE-Digital/schools-experience/commit/4d008da0e0edf4a9e47fe6d66eebda827a45f46a

This approach offered complete control over the solution, and gave
that team the flexibility to integrate closely with the DfE Gitis CRM
service which is a requirement for their system. On the other hand,
it took time and effort to build and will need to be maintained by
that team.

We analysed our options using a table where each option had a column,
and there were three rows: benefits, costs and mitigations.

The conclusion:

`passwordless` is good in the short term, but it is a relatively risky
dependency to take on, and it will not easily adapt to changing
requirements. We could mitigate this by carefully wrapping it, but
wrapping an authentication system is tricky as it touches many parts
of the application.

`devise` brings a little bit of unwelcome voodoo to our codebase but
offers a quick way to deliver the feature with some confidence. We
could mitigate the complexity via documentation, and by helping the
team learn about `devise`. Because the library is so popular we do not
consider learning about it to be a waste of effort, and we're less
concerned than we might otherwise be about adding library-specific
code.

The DIY approach is very appealing, but we do not have time to do it
and look after it.

## Decision

Use Devise, and brush up the spike branch to implement Magic Links for
production.

## Consequences

We will be able to ship Magic Links and feel confident our app is
secure. Should we need to add e.g. passwords or other Devise models -
for instance, we are already talking about this for Provider sign-in -
we will be able to make those changes in reasonably short order.

However, we now have a new dependency which is cutting across a lot
of our app, and we're adding customisation to it. We need to make sure
that we document the Magic Link implementation so that when we're
gone, the bits and pieces that make it up are still comprehensible to
the next person.
