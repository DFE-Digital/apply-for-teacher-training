# 10. Use cookies for sessions

Date: 2020-01-14

## Status

Accepted

## Context

This application needs user sessions to allow users (candidates, providers, referees, support staff) to sign in. Rails offers a number of options for this. Each have a trade-off.

### Cookie sessions

All session information is saved in a cookie. The cookie is encrypted to avoid the user changing or reading the data.

Pro:

- It does not interact with other infrastructure
- It's the Rails default, well understood by developers

Con:

- When the user signs out, we do not invalidate the session. This means that if the user has made a copy of the cookie, they (or an attacker) can sign themselves back in.
- Users cannot sign out sessions on other devices (remote sign out)

### Storage based cookies

This mechanism relies on a session ID being saved in a cookie. The session ID corresponds to a record either in a traditional database (PostgreSQL in our case) or in a caching service (Memcached, Redis).

Pro:

- On sign out, the session is deleted and cannot be revived
- Sessions can be invalidated "remotely", to allow sign out of other devices

Con:

- Uses other infrastructure - slight performance overhead, risk of services being unavailable
- Sensitive data is stored in a database

## Decision

Use session cookies.

## Consequences

We accept the downsides of using session cookies.
