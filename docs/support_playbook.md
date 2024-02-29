# Apply Dev Support Playbook

## Support Trello board

https://trello.com/b/dcWOMFyp/

## Add a course to submitted applications

You can add a course to a submitted application in the Support UI if the maximum number of course choices has not been exceeded.

## References

### Re-send a reference email for a referee

First consider simply sending the referee a link to the reference form. Use the email log to find the body of the original reference request (or a chaser) and pick out the URL.

If a re-send of the email is necessary:

```ruby
RefereeMailer.reference_request_email(reference).deliver_now
```

### Re-add a referee

If the request is coming from the candidate, ask them to delete the reference and request it again.

If the request is from a referee (eg—an accidental refusal), use the “Undo refusal” feature in the support interface to move the reference back to feedback_requested. If the referee needs the reference link, see the section on [re-sending a reference email](#re-send-a-reference-email-for-a-referee).

### Uncancel a reference that was cancelled by support

Candidates can cancel and reinstate references themselves, so this shouldn't typically be something the support dev handles.

## Unlock Application Form Sections for Candidate Editing

Occasionally, there might be a request to unlock certain sections of an application form, allowing the candidate to make edits. Ensure you receive confirmation from the policy team before proceeding.

### Steps:

1. **Confirmation from Policy Team:**
   - Before making any changes, confirm that the policy team has approved the request to unlock the application form sections.

2. **Activate the Feature Flag:**
   - Go to the `support/settings/feature-flags` page.
   - Activate the `Unlock application for editing` feature flag.

3. **Edit Application Sections:**
   - After activating the feature flag, a new column titled `Is this application editable` will appear in the support interface.
   - Support agents can use this to unlock specific sections of the application form for the candidate to edit.

4. **Post-Editing:**
   - Ask support to let you know once they have unlocked the sections for the candidate so you can deactivate the feature flag again. The candidate will then have 5 days to make their edits.


## Work experience

### Add Work Experience

Create a new ApplicationWorkExperience of the appropriate type and save it against the ApplicationForm.

### Update Work Experience

Find records:

```ruby
# For paid experience
experiences = ApplicationForm.find_by(support_reference: _reference_string).application_work_experiences

# For unpaid experience and volunteering:
experiences = ApplicationForm.find_by(support_reference: _reference_string).application_volunteering_experiences
```

Update:

```ruby
# Select the experience record you want to update, e.g. the first one
experience = experiences.first
experience.update(
  details: "Interpreting a brief from a client and making it a workable design, High profile clients meant I had to think on my feet and deliver what the client wanted immediately.",
  audit_comment: "Updated on candidate's request: https://becomingateacher.zendesk.com/"
)
```

## Qualifications

### Candidate unable to submit because degree info incomplete

We've seen this happen due to a `nil` value for `predicted_grade`. To fix this update `predicted_grade` to false.

### Update qualifications

**Adding equivalency**

TODO: rewrite this section

Create the same qualification locally, turn the relevant fields into JSON, paste that into the prod shell, parse it and assigned attrs 😥 `qualification.as_json(only: [fields]).to_json`

**Change grade**

```ruby
ApplicationQualification.find(ID).update!(grade: 'D', audit_comment: 'Updating grade following a support request, ticket ZENDESK_URL')
```

**Change start and graduation date**

```ruby
ApplicationQualification.find(ID).update!(start_year: '2011', award_year: '2014', audit_comment: 'Updating an application after a user requested a change, ticket ZENDESK_URL'
```

## Personal statement

### Update personal statement

The personal statement uses the following database field:

- `becoming_a_teacher` - Why do you want to be a teacher? (‘Vocation' in support)

```ruby
ApplicationForm.find(ID).update!(becoming_a_teacher: 'new text', audit_comment: 'Updating grade following a support request, ticket ZENDESK_URL')
```

## Courses and course locations

### Changing a course or course location

This is possible via the support UI, except in the case where the provider has requested a change from a non-salaried to a salaried course:

```ruby
non_salaried_application_choice = ApplicationChoice.find(APPLICATION_CHOICE_ID)
salaried_course_option = CourseOption.find(COURSE_OPTION_ID)
audit_comment = ZENDESK_URL

non_salaried_application_choice.update_course_option_and_associated_fields!(
  salaried_course_option,
  audit_comment:,
  other_fields: {
    course_option: salaried_course_option,
    course_changed_at: Time.zone.now,
  },
)
```

### Changing a deferred applicant's course in the new cycle

This is possible via the support UI.

If the course doesn't exist in the previous cycle we'll need them to confirm the offer first, then we can change the course to the new course in the current cycle.

## Confirm deferral in the console

If the course details have changed from one cycle to another, provider users should contact support to request the changes. To confirm a deferral through the console:

```ruby
application_choice = ApplicationChoice.find(APPLICATION_CHOICE_ID)
new_course_option = CourseOption.find(NEW_COURSE_OPTION_ID)
zendesk_url = ZENDESK_URL

# confirm the deferral in a new course
application_choice.update_course_option_and_associated_fields!(new_course_option, audit_comment: zendesk_url)
```

A **conditional offer** would move the candidate to a pending conditions state:

```ruby
# change the status to pending conditions (if it is a conditional deferred offer)
application_choice.update!(status: 'pending_conditions', audit_comment: zendesk_url)
```

An **unconditional offer** would move the candidate to a recruited state:

```ruby
# change the status to recruited (if it is an unconditional deferred offer)
application_choice.update!(status: 'recruited', audit_comment: zendesk_url)
```

## Offers

### Rollback a providers offer

To rollback a providers offer do the following:

- Set the status of the application choice back to `awaiting_provider_decision``
- set `offer_at` back to `nil`
- Set `decline_by_default_at` back to `nil`
- Add the Zendesk ticket URL as the `audit_comment`

E.G

```
ApplicationForm.find(ID).application_choices.find(id).update(status: 'awaiting_provider_decision', offered_at: nil, decline_by_default_at: nil, audit_comment: ZENDESK_URL)
```

### Make or change offer

If the current application status is `awaiting_provider_decision` use [MakeOffer](../app/services/make_offer.rb) service.

If the current application status is `offer` use [ChangeOffer](../app/services/change_offer.rb) service.

### Change offer conditions

This is possible via the support UI.

Conditions can be added by creating a new [OfferCondition](../app/models/offer_condition.rb) object and then pushing it into the `conditions` collection, for example:

```ruby
condition = OfferCondition.new(text: 'You need to pass an 8 week SKE in Mathematics')
ac.offer.conditions << condition
```
The default state for an `OfferCondition` object is `pending`.

### Reverting an application choice to pending conditions

If an application choice status is `recruited`, `conditions_not_met` or `offer_deferred` it can be reverted to `pending_conditions` using the support UI.

### Reverting an application choice from pending conditions

A provider can make an offer to a candidate and then decide to retract the offer. The if the candidate accepts the offer before the provider can withdraw it, the application can be in the `pending_conditions` state. The provider wants the application status should change from `pending_conditions` to `rejected`.
A better approach might be to update the status of the application from `pending_conditions` to `offer` and then the provider can withdraw the offer in the provider interface. This will send a notification to the candidate at the same time.

In this case, other applications belonging to the candidate may be automatically withdrawn because they accepted an offer. These applications should be "unwithdrawn". This is possible in the support interface once the offending application is changed from `pending_conditions` to `offer`.

[Withdraw Offer Service](../app/services/withdraw_offer.rb)


### Revert a rejection

Providers may need to revert a rejection so that they can offer a different course or if it was done in error.

The rejection can be reverted via the Support UI when viewing the application
choice.

If a candidate has had a course rejected in error but wishes to replace their course option with another offered by a _different_ provider,
then following reverting the rejection via the Support UI, you will need to [withdraw the course option via the console](#change-providercourse),
before adding a new course choice via the Support UI.

### Revert a withdrawn offer

This must be done manually via the console.

```ruby
choice = ApplicationChoice.find(id)
choice.update!(status: "interviewing", offer_withdrawal_reason: nil, offer_withdrawn_at: nil, audit_comment: ZENDESK_URL)
```

### Revert a candidate withdrawn application

If a candidate accidentally withdraws their application, it can be reverted via the Support UI

### Accept offer declined by default

It can happen that a candidate started training but forgot to accept the offer in Apply and it was declined by default.

Update [ApplicationChoice](../app/models/application_choice.rb) to `recruited`.

```ruby
ApplicationChoice.find(_id).update!(status: :recruited, decline_by_default_at: nil, audit_comment: "ZENDESK_URL")
```

## Delete an account / application

If an individual requests we delete their data we have 1 month to comply with this. At the same time we need the record to track for stats purposes.

Use the [DeleteApplication](../app/services/delete_application.rb) service if the application has not been submitted yet. You may use the `force` option provided it has been cleared with the support team.

If the application has been submitted, start a discussion to determine what steps we should take (eg - contacting the provider before deleting anything on our side).

Whatever is decided, we should (at a minimum) do the following:
- Remove all data from the application where possible
- Add fake data where not possible (`email_address`)
- `Candidate.find_by(email_address: 'old_email').update!(email_address: 'deleted_on_user_requestX@example.com')`

## Provider users and permissions

### Provider login issues

**Your account is not ready**

Advise the support agent to ask the user to try logging into Manage in an incognito / private browsing window and ensure correct DfE credentials are being used e.g. check their email address is registered with Manage as users can have this problem if they have multiple DfE Signin accounts.

**Page not found**

Instruct user to sign out of DfE SignIn and log into Apply again from the browser (rather than the email link)

**Your email address is not recognised**

This can be an issue if a user has an old deactivated DfE SignIn account and therefore the wrong DfE SignIn token is associated with their account. To fix it update `dfe_sign_in_token`.<sup>[to what?]</sup>

### Edit relationship permissions

This is possible via the Support UI

`https://www.apply-for-teacher-training.service.gov.uk/support/providers/$ID/relationships`

### Add users in bulk

**Only for brand new users as part of HEI onboarding.**

```ruby
admins = [
  {
    first_name: 'Anne',
    last_name: 'Admin',
    email_address: 'anne.admin@example.com',
  },
  {
    first_name: 'Andrew',
    last_name: 'Nother-Admin',
    email_address: 'a.nother-admin@example.com',
  }
]

admins.each do |admin|
 provider_user = ProviderUser.create!(admin)
 provider.provider_permissions << ProviderPermissions.new(
   provider_user: provider_user,
   manage_users: true,
   view_safeguarding_information: true,
   make_decisions: true,
   manage_organisations: true,
   view_diversity_information: true,
 )
 InviteProviderUser.new(provider_user: provider_user).call!
end

users = [
  {
    first_name: 'Archibald',
    last_name: 'User',
    email_address: 'a.user@example.com',
  },
  {
    first_name: 'Alice',
    last_name: 'Nother-User',
    email_address: 'a.nother-user@example.com',
  },
]

users.each do |user|
 provider_user = ProviderUser.create!(user)
 provider.provider_permissions << ProviderPermissions.new(
   provider_user: provider_user,
   manage_users: false,
   view_safeguarding_information: false,
   make_decisions: false,
   manage_organisations: false,
   view_diversity_information: false,
 )
 InviteProviderUser.new(provider_user: provider_user).call!
end
```

### Reinstate a reference

When an application endup in an unsuccessful state we change the outstanding
references to "cancelled".

If we need to reinstate a reference we have a service called
ReinstateReference which will revert the reference from 'cancelled' to
'feedback_request' and will send an email to the referee as well.

```ruby
  ReinstateReference.new(reference, audit_comment: ZENDESK_URL).call
```

### Disable notifications for an HEI's users and all users at SDs for which they are the sole accredited body

```ruby
provider = Provider.find(ID)
providers_with_courses_we_ratify = Provider.where(id: provider.accredited_courses.distinct.pluck(:provider_id))
providers_exclusively_ratified_by_us = providers_with_courses_we_ratify.select do |p|
  Course.where(provider_id: p).distinct.pluck(:accredited_provider_id) == [provider.id]
end

users_to_disable_notifications_for = provider.provider_users + providers_exclusively_ratified_by_us.flat_map(&:provider_users)

users_to_disable_notifications_for.map { |u| u.update!(send_notifications: false) }
```

## Publish sandbox

### Add users

To help test the Vendor API integrations in Sandbox, Providers will request they be added to the Publish Sandbox, where they can add test courses.

Raise PIM and run `make <env> ssh`

Once you're in, `$ cd /app`

You can now create a CSV which will be used when the rake tasks run.

There are two rake tasks, which either import new users, or new providers. You can name the CSV however you want, as long as you refer to it in the rake call.

`$ bin/rails sandbox:create_providers['./providers.csv']`

`$ bin/rails sandbox:import_users['./users.csv']`

You'll need a CSV for both, with the format specified in the tasks `lib/tasks/sandbox.rake`:

For providers:

```
name,code,type,accredited_body
Provider one,ABC,scitt,true
Provider two,DEF,lead_school,false
```

For users:

```
name,email_address,provider
Dave Test,dave@example.com,Provider name SCITT
```

To add a user, you'll need the `provider_name` for the provider you want to add them to. To add a user to multiple providers, create one row per provider.

If you need to, you can get into the rails console to look for various things

`$ bin/rails c`

To see if a provider name exists
```ruby
=> Provider.where(provider_name: "University of BAT")
```

Adding a new provider involves setting the provider name and code - I found these by going onto the [apply sandbox](https://sandbox.apply-for-teacher-training.service.gov.uk/support/providers?onboarding_stages%5B%5D=synced&onboarding_stages%5B%5D=dsa_signed), and looking for the required provider. This had the exact name and code.

## Candidate login issues

**Sorry, but there is a problem with the service**

Check logs in Kibana. If there is a 422 Unprocessable Entity response for this user, advise the support agent to go back to the candidate with:

> You are experiencing the problem because your browser is storing some old data. We would suggest closing all the tabs, which have Apply service open and clicking the link again: https://www.apply-for-teacher-training.service.gov.uk/candidate/account
>
> If this problem persists please get in touch and we will investigate further.
