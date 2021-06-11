# Apply Dev Support Playbook

## Support Trello board

https://trello.com/b/dcWOMFyp/

## Sentry errors

Outside of assisting with user support, the support developer should ensure that trello cards are added for any issues logged by Sentry, and set the issues to resolved on the service, so we can easily identify and prioritise recurring errors.

## Change the candidate's details

You can make these changes in the Support UI:

Changes to candidate's details: Full name, Date of birth, Nationality, Domicile, Phone number, Email address, Address
Changes to references: Referee's name, Email address, Relationship to candidate, Reference

Any other changes need to be made by a developer.

## Add a course to submitted applications

You can add a course to a submitted application in the Support UI, if the maximum number of course choices has not been exceeded.

## Re-send a reference email for a referee

First consider simply sending the referee a link to the reference form. Use the email log to find the body of the original reference request (or a chaser) and pick out the URL.

If a re-send of the email is necessary:

```ruby
RefereeMailer.reference_request_email(reference).deliver_now
```

## Re-add a referee / resend emails for refused reference

If the request is coming from the candidate, ask them to delete the reference and request it again.

If the request is from a referee (eg—an accidental refusal), use the “Undo refusal” feature in the support interface to move the reference back to feedback_requested. If the referee needs the reference link, see this section.

## Uncancel a reference that was cancelled by support

Candidates can cancel and reinstate references themselves, so this shouldn't typically be something the support dev handles.

## Candidate unable to submit because degree info incomplete

We've seen this happen due to a `nil` value for `predicted_grade`.
To fix this update predicted_grade to false.

## Add Work Experience

Create a new ApplicationWorkExperience of the appropriate type and save it against the ApplicationForm.

## Update Work Experience

**Find them**

```ruby
ApplicationForm.find_by(support_reference: _reference_string).application_work_experiences
```

**Update**

```ruby
ApplicationWorkExperience.find(_id).update(
  details: "Interpreting a brief from a client and making it a workable design, High profile clients meant I had to think on my feet and deliver what the client wanted immediately.",
  audit_comment: "Updated on candidate's request: https://becomingateacher.zendesk.com/"
  )
```

**For unpaid experience and volunteering**

```ruby
ApplicationForm.find_by(support_reference: _reference_string).application_volunteering_experiences
```


## Update personal statement

The personal statement is split into database fields:
becoming_a_teacher - Why do you want to be a teacher? (‘Vocation' in support)
subject_knowledge - What do you know about the subject you want to teach?

Make sure you know which part you are amending.
Add \r\n\r\n for carriage return.

```ruby
ApplicationForm.find(_id).update!(becoming_a_teacher: 'new text', subject_knowledge: 'new_text', audit_comment: 'Updating grade following a support request, ticket ZENDESK-LINK')
```


## Update qualifications

**Adding equivalency**

TODO: rewrite this section

Create the same qualification locally, turn the relevant fields into JSON, paste that into the prod shell, parse it and assigned attrs 😥 qualification.as_json(only: [fields]).to_json

**Change grade**

```ruby
ApplicationQualification.find(_id).update!(grade: 'D', audit_comment: 'Updating grade following a support request, ticket ZENDESK-LINK')
```

**Change start and graduation date**

```ruby
ApplicationQualification.find(_id).update!(start_year: '2011', award_year: '2014', audit_comment: 'Updating an application after a user requested a change, ticket ZENDESK-LINK'
```

## Make or change offer

If the current application status is `awaiting_provider_decision` use MakeAnOffer service.

If the current application status is `offer` use ChangeOffer service.

## Change provider/course

Sometimes a provider has no room for an accepted candidate and they refer them to another provider. In this case we create a new ApplicationChoice for the new course_option by following these steps:

- Get the old application choices to withdraw later

For example by candidates email:

```ruby
old_application_choice = ApplicationForm.find_by(candidate_id: Candidate.find_by(email_address: 'example@email.com').id).application_choices.first
```

- Add course after submission

Find the course option for the new course. As the course code is not unique make sure to include the provider details.

```ruby
course_option = CourseOption
  .where(
    course_id: Course.where(code: _course_code, provider: Provider.find_by(code: _provider_code)),
    recruitment_cycle_year: RecruitmentCycle.current_year
  )
).first
```

- Find the application form

Eg -

```ruby
application_form = old_application_choice.application_form
```

- Create a new ApplicationChoice associated with the application form

Then submit the new application choice to the provider by calling a service:

```ruby
SupportInterface::AddCourseChoiceAfterSubmission.new(application_form: application_form, course_option: course_option).call
```

- Withdraw the previous one

```ruby
ApplicationStateChange.new(old_application_choice).withdraw!
old_application_choice.update(withdrawn_at: Time.zone.now)
```

## Change offer conditions

**Define new conditions**

```ruby
offer = {"conditions"=>["Fitness to Teach check", "Disclosure and Barring Service (DBS) check", "Suitable host school agreed", "See sight of original certificates and identification documents"]}

ApplicationChoice.find(_id).update(offer: offer)
```

**Add a new condition to an offer**

Make sure the support agent confirmed that the candidate is aware of the changes.

```ruby
application_choice = ApplicationChoice.find(_id)
offer = application_choice.offer
offer["conditions"] << "$NEW_CONDITION"
application_choice.update!(offer: offer, audit_comment: "Support request by provider to amend conditions")
```

**Change the offer conditions after it was accepted by the candidate**

Make sure the support agent confirmed that the candidate is aware of the changes.

```ruby
offer = {"conditions"=>["Fitness to Teach check", "Disclosure and Barring Service (DBS) check", "Suitable host school agreed", "See sight of original certificates and identification documents"]}
```

Find ApplicationChoice and new CourseOption:

```ruby
ApplicationChoice.find(_id).update(offer: offer)
```

## Revert an application choice to pending_conditions

This can be requested if a provider accidentally marks an application as conditions not met.

```ruby
a = ApplicationForm.find_by!(support_reference:'$REF')
a.application_choices.select(&:conditions_not_met?).first.update!(status: :pending_conditions, conditions_not_met_at: nil, audit_comment: 'Support request following provider accidentally marking them as conditions_not_met.')
```

## Revert a rejection

Providers may need to revert a rejection so that they can offer a different course or if it was done in error.

This can be done via the Support UI when viewing the application choice.

## Revert a withdrawn offer

If a provider accidentally withdraws an offer, they can make the offer again via the respond UI, which isn't linked from anywhere:

https://www.apply-for-teacher-training.service.gov.uk/provider/applications/:application_choice_id/respond

Example: https://becomingateacher.zendesk.com/agent/tickets/11274

## Revert a candidate withdrawn application

If a candidate accidentally withdraws their application, it can only be manually reverted through the rails console.

```ruby
ApplicationChoice.find(_id).update!(status: :awaiting_provider_decision, withdrawn_at: nil, withdrawal_feedback: nil, audit_comment: "Support request after candidate withdrew their application in error: #{_zendesk_url}")
```

## Accept offer declined by default

It can happen that a candidate started training but forgot to accept the offer in Apply and it was declined by default.

Update ApplicationChoice to `recruited`.

```ruby
ApplicationChoice.find(_id).update!(status: :recruited, decline_by_default_at: nil, audit_comment: "Support request: #{_zendesk_url}")
```

## Delete an application

If an individual requests we delete their data we have 1 month to comply with this. At the same time we need the record to track for stats purposes.

Use the `DeleteApplication` service if the application has not been submitted yet.

If the application has been submitted, start a discussion to determine what steps we should take (eg - contacting the provider before deleting anything on our side).

Whatever is decided, we should (at a minimum) do the following:
- Remove all data from the application where possible
- Add fake data where not possible (email_address)
- `Candidate.find_by(email_address: 'old_email').update!(email_address: 'deleted_on_user_requestX@example.com')`

## Change provider permissions

Advise the support agent that it can be done in the UI

`https://www.apply-for-teacher-training.service.gov.uk/support/providers/$ID/relationships`

## Add provider users in bulk

ONLY FOR BRAND NEW USERS AS PART OF HEI ONBOARDING.

```ruby
admins = [ ['first_name', 'last_name', 'email_address'], ['first_name', 'last_name', 'email_address'] ]
users = [ ['first_name', 'last_name', 'email_address'], ['first_name', 'last_name', 'email_address'] ]
admins.each do |line|
 provider_user = ProviderUser.create!(
   email_address: line[2],
   first_name: line[0],
   last_name: line[1],
 )
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
users.each do |line|
 provider_user = ProviderUser.create!(
   email_address: line[2],
   first_name: line[0],
   last_name: line[1],
 )
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

https://ukgovernmentdfe.slack.com/archives/CQA64BETU/p1611153056062300

## Disable notifications for an HEI's users and all users at SDs for which they are the sole accredited body

```ruby
provider = Provider.find(id)
providers_with_courses_we_ratify = Provider.where(id: provider.accredited_courses.distinct.pluck(:provider_id))
providers_exclusively_ratified_by_us = providers_with_courses_we_ratify.select do |p|
  Course.where(provider_id: p).distinct.pluck(:accredited_provider_id) == [provider.id]
end

users_to_disable_notifications_for = provider.provider_users + providers_exclusively_ratified_by_us.flat_map(&:provider_users)

users_to_disable_notifications_for.map { |u| u.update!(send_notifications: false) }
```

https://ukgovernmentdfe.slack.com/archives/CQA64BETU/p1611922559119000

## View UCAS match files

After UCAS receives our file with applications, they match it against the candidates in their database. They then upload a new zipped file to the DFEApplicantData/matched_dfe_apply_itt_applications folder on Movit.
You may need to view them if there is a problem with UCAS matches we receive.

- Go to https://transfer.ucas.com
- Get the UCAS_USERNAME and UCAS_PASSWORD from Azure Pipeline under ‘Properties'

## Add Providers/Users to Publish Sandbox

To help test the Vendor API integrations in Sandbox, Providers will request they be added to the Publish Sandbox, where they can add test courses. After getting a list of Providers and their users please follow the steps outlined here to add them to the Publish Sandbox: https://hackmd.io/suMsLlLQTFKTTwcWg_7hUg

## Provider login issues

**Your account is not ready**

Advise the support agent to ask the user to try logging into Manage in the incognito window and ensure correct DfE credentials are used i.e. email registered by Manage as users can have this problem if they have multiple DfE Signin accounts.

**Page not found**

Instruct user to sign out of DFE sign in and log into Apply again from the browser (rather than the email link)

**Your email address is not recognised**

This can be an issue if a user has an old deactivated DfE SignIn account and therefore the wrong DfE SignIn token is associated with their account. To fix it update dfe_sign_in_token.

## Candidate login issues

**Sorry, but there is a problem with the service**

Check logs in Kibana. If there is a 422 Unprocessable Entity response for this user, advise the support agent to go back to the candidate with:


You are experiencing the problem because your browser is storing some old data. We would suggest closing all the tabs, which have Apply service open and clicking the link again: https://www.apply-for-teacher-training.service.gov.uk/candidate/account
If this problem persists please get in touch and we will investigate further.
