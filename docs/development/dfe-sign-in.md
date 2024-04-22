# DfE sign-in set-up

## Environments

DfE sign-in has the following environments:

- [Dev](https://dev-services.signin.education.gov.uk/)
- [Test](https://test-services.signin.education.gov.uk): used by Apply qa
- [Preprod](https://pp-services.signin.education.gov.uk/)
- [Production](https://services.signin.education.gov.uk/): used by Apply staging, sandbox, production

## DfE Sign-in

The Provider interface at `/provider` and Support interface at
`/support` are both protected by DfE's SSO provider DfE Sign-in.

### Environments

In development and QA we use the **Test** environment of DfE Sign-in:

[Manage console (test)](https://test-manage.signin.education.gov.uk)

```sh
# .env
DFE_SIGN_IN_ISSUER=https://test-oidc.signin.education.gov.uk
```

In staging, production and sandbox we use the **Production** environment of DfE Sign-in:

[Manage console (production)](https://manage.signin.education.gov.uk)

```sh
# .env
DFE_SIGN_IN_ISSUER=https://oidc.signin.education.gov.uk
```

## Service configuration

The configuration is done via the DSI "Manage" application:

- [Manage Test](https://test-manage.signin.education.gov.uk/)
- [Manage Production](https://manage.signin.education.gov.uk/)

Request access via the [DSI service-now form](https://dfe.service-now.com/serviceportal?id=sc_cat_item&sys_id=0c00c1afdb6bc8109402e1aa4b961937&sysparm_category=2f6e34afdb6bc8109402e1aa4b9619aa).

### Service details

- Service name: Used to display the service name in the Manage app list of services. It is also included in the JWT token.
  - "Manage Teacher Training Applications"
- Description: Displayed on the Manage app, on the Support app, on the DSI homepage
- Home Url: Main site URL, used as landing page from DSI and after sign out
  - "<https://www.apply-for-teacher-training.service.gov.uk/provider>"

### OpenID Connect

- Client Id: Can be chosen, must be unique, alphabetical, 8 characters maximum.
  - "apply"
- Client secret: generated, must be stored as secret and provided to the Apply webapp. It is sent in requests to DSI.
- Redirect Urls: Whitelist of post sign in URLs
  - <https://www.apply-for-teacher-training.education.gov.uk/auth/dfe/callback>
  - <https://www.apply-for-teacher-training.service.gov.uk/auth/dfe/callback>
  - and all other environments
- Logout redirect Urls: Whitelist of post sign out URLs
  - <https://www.apply-for-teacher-training.service.gov.uk/auth/dfe/sign-out>
  - <https://www.apply-for-teacher-training.service.gov.uk/provider/sign-out>
  - and all other environments

### Grant types

See [OAuth 2.0 Grant types](https://oauth.net/2/grant-types/)

- authorization_code
- refresh_token

### Response types

See [OAuth 2.0 Multiple Response Type Encoding Practices](https://openid.net/specs/oauth-v2-multiple-response-types-1_0.html)

- none selected

### Token endpoint authentication method

Defines whether client sends encrypted post. This is mostly for dotnet apps.

- "none"

### API

- Secret: Access to [DSI public API](https://github.com/DFE-Digital/login.dfe.public-api) which is specific to DSI, not OAuth. It is generated, must be stored as secret and provided to the Apply webapp.

## Application variables

- `DFE_SIGN_IN_SECRET`: Secret string used to encode/decode the payload when communicating with DSI. It it generated on the manage service page in OpenID Connect / Client secret
- `DSI_API_URL`: DSI API endpoint to access extra data from the API. May point to preprod or prod DSI environment.
- `DSI_API_SECRET`: Secret string used to decode the payload from DSI API. It it generated on the manage service page in API / Secret.
- `DFE_SIGN_IN_CLIENT_ID`: Client ID used to connect to DSI via OIDC. It it set on the manage service page in OpenID Connect / Client Id.
- `DFE_SIGN_IN_ISSUER`: DSI OIDC environment endpoint for authentication. May point to preprod or prod DSI environment.

## User management

DfE Sign-In is used for support users as well as provider users. Apply connects to the DSI API to add the users.

### Support users

They can be added by another support user from the support page. The user must already be registered with DfE Sign-In. Their email and DSI id are required.

### Provider users

They can be added to an existing provider by a support user or by another provider user. First name, Last name and email are required.
