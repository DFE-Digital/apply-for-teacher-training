# Provider User Personas

## Background

Many of the features of Manage now depend on users and organisations having specific permissions set up.
To avoid people having to set up provider users with these properties every time, we now set up some common test case
users in review apps.

## Available personas

The following users are the available personas in review apps.
They can be used by going to Manage sign-in page, clicking "Sign in using DfE Sign-in (bypass)"
and entering the UID in the Uid field on the Sign In form.

### Self ratifying provider

#### Admin
UID: `persona-self-ratified-provider-admin`

This user belongs to a single provider, which has no relationships with other providers.
The user has both `manage_organisations` and `manage_users` permissions.

#### User
UID: `persona-self-ratified-provider-user`

This user belongs to a single provider, which has no relationships with other providers.
The user can only view applications.

### Multiple providers

#### Admin
UID: `persona-multiple-providers-admin`

This user belongs to multiple providers.
The user has both `manage_organisations` and `manage_users` permissions.

#### User
UID: `persona-multiple-providers-user`

This user belongs to multiple providers.
The user can only view applications.

### Provider with no courses

#### Admin
UID: `persona-no-courses-provider-admin`

This user belongs to a single provider which has no open courses.
The user has both `manage_organisations` and `manage_users` permissions.

#### User
UID: `persona-no-courses-provider-user`

This user belongs to a single provider which has no open courses.
The user can only view applications.
