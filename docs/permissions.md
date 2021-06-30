# Permissions in Apply

## Background

Due to the complexity of user and organisational permissions, knowledge sharing between members of the team has not been as straightforward. This document is an attempt to rectify that and enable all developers to gain a thorough understanding of how permissions work across the application.

## Available Permissions

The following set of permissions are used across the app.

### Related to org management

- Manage Users

  Enables a provider user to invite or delete users and set their permissions.

- Manage Organisations

  Enables a provider user to manage/change permissions between different organisations.

### Related to application management

- Set Up interviews

  Enables a provider user to create, edit and delete interviews.

- Make decision

  Enables a provider user to make and amend offers, and reject applications.

- View safeguarding information

  Allows provider users to view sensitive information about the candidate.

- View diversity information

  Allows provider users to view diversity information about the candidate.


## Provider User Permissions

![Screenshot of Provider user permission](docs/provider_user_permissions.png)
<sup id='1'>[1](#footnote-1)</sup> <sup id='2'>[2](#footnote-2)</sup> <sup id='3'>[3](#footnote-3)</sup>

<a name="footnote-1">1</a>:  The blue decision nodes represent user level checks

<a name="footnote-2">2</a>:  The red decision nodes represent organisation level checks

<a name="footnote-3">3</a>:  Where org level permissions are applied the user level permissions must match the permissions of the organisation


### User level permissions

All permissions are configurable and always enforced at user level.

What that means is that a provider user can only perform a certain action, e.g. _View safeguarding information_, if they have that permission set against their account for either the training or the ratifying provider of the course associated with the application that they are trying to access.


### Organisational Permissions

Some of the available permissions are enforceable at organisation level. More specifically, these are permissions related to most actions that can be performed on applications, besides _Set Up interviews_.

- Make decisions
- View safeguarding information
- View diversity information

When the course of an application choice is not self ratified, these permissions must also be configured for the provider that the provider user belongs to in order for them to be able to take the relevant action.

So, for example, if Jane is able to **Make decisions** on behalf of _Provider A_ who is the training provider for a course ratified by _Provider B_, she can only use this permission if _Provider A_ is also able to **Make decisions** for any courses ratified by _Provider B_. However if the course is self ratified then she will be able to **Make decisions** for it, as in that instance organisational level permissions will not be relevant.


## Support User Permissions

![Screenshot of Support user permission](docs/support_user_permissions.png)

A support user is able to perform all actions without any restrictions.
