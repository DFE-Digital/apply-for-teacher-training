# 12. Improve security of the support interface

Date: 2020-03-30

## Context

Members of the Apply team have access to a section of the service called [Support](https://www.apply-for-teacher-training.service.gov.uk/support). It exposes a lot of data and allows make changes to the site. We use DfE Sign-in for access to the support interface.

There are 2 concerns around the security of Support:

- DfE Sign-in uses a username and password for sign in. It does not offer 2 factor authentication. This means that an attacker could steal or guess a password and gain access to Support.
- We do not have an automated leavers process that revokes access to DfE Sign-in when people leave. This leaves open the possibility that former staff retain access to Support.

As part of proactive security work we’ve looked into improving the security of Support.

## Decision

We allow access only with `@digital.education.gov.uk` and `@education.gov.uk` addresses to Support. These email systems both have 2FA enabled. This means that if the user can prove that they have access to their email, we can be reasonably sure that they are who they say they are.

The solution we intend to build works by requiring Support users to confirm that they have access to their email every week, on each machine they use to access the service. This also proves that they’re still employed by DfE.

The technical implementation:

When a support user visits the site they sign in as usual using DfE Sign-in. When they return to Apply, we check if they have a valid “email\_confirmed” cookie set. If not, they’ll see a screen saying that they’ve received an email with a confirmation link. If they click the link, we’ll set the “email\_confirmed” cookie and allow them access to the site.

The “email\_confirmed” cookie is [signed to avoid tampering](https://apidock.com/rails/v6.0.0/ActionDispatch/Cookies/ChainedCookieJars/signed). It contains the user ID of the user (so it cannot be shared) and an expiry date 7 days in the future (so that emails have to be reconfirmed every 7 days).

## Other options that have been considered

For this ADR we considered a wide variety of options. In addition to solving the 2 issues described above, we looked at how straightforward the implementation would be, the ease of use, the level of security it would provide, and if it could be re-used to provide additional security for the provider interface.

All options have their trade-offs. We’ve chosen to go with the Email confirmation option, since it is fairly straightforward to implement and it fulfills our 2 requirements (unlike B, C, D, E, F). Option G (SSO) is not possible as we need to support users on the `@education.gov.uk` domain which is not a Google apps domain.

| What | Description | Advantage | Disadvantage |
| -- | -- | -- | -- |
| 🏆 A. Email confirmation | Confirmation email when you sign in. Only if we mandate support users use \*.education.gov.uk addresses, which have 2FA | Proves user works at DfE. Could be re-used for provider users, but only to make sure they still work for the school | User frustration when emails get caught in spam or not received at all. Will not work as 2FA for provider users as we cannot prove that their email has 2FA. |
| B. SMS | On successful login with password, the user gets an SMS with a one-time code | Easy for users to understand. Easy integration with GOV.UK Notify. Could be re-used for provider users. Does not require a smartphone. | Does not prove that the user still works at DfE. SMS is considered not secure enough for 2FA by some security experts. We do not have people’s phone numbers, so we’d have to get them. |
| C. Authenticator app | Use an integration via a gem, users scan a QR code using their app (e.g. Authy, Google Authenticator, etc) and then whenever they login we ask them for the latest auto-generated code | Widely used. Could be re-used for provider users. | Not everyone has a smartphone. Corporate phones might prevent app installs. It’s a bit of a faff to set up for users. Does not prove that the user still works at DfE. |
| D. Hardware key (Yubikey) | Support users plug in a Yubi key and prove their identity | Easy to use once set up. Plenty of hardware options available | Cost and procurement. We’d need a lot of processes to provide new devices, revoke old devices, and manage lost. Will not work for provider users. Does not prove that the user still works at DfE. |
| E. Replace DfE Sign-in with magic links | A lot of emails already have 2FA / MFA - we could get rid of passwords and just use magic links. Only if we mandate support users use \*.education.gov.uk addresses, which have 2FA | Could be used to provide fallback when DfE Sign-in is down. Proves user works at DfE. | Will not work as 2FA for provider users as we cannot prove that their email has 2FA |
| F. DfE Sign-in | DfE Sign-in has some form of 2FA built into it | We do not have to do anything. Works for provider users. | Investigated by Claim team, it’s apparently not production ready |
| G. Using Google SSO for Support login | Use Google Apps SSO for digital.education.gov.uk for login | Gets rid of the DfE Sign-in requirement for support users. No additional login step for DfE users already signed into their email accounts. Minimal changes to our app (we use omniauth)Proves user works at DfE. | Not everyone has @digital.education.gov.uk email address, some civil servants only have a @education.gov.uk address. Will not work for provider users. |
