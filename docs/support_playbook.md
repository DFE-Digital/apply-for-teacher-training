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

## Work experience

### Add Work Experience

Create a new ApplicationWorkExperience of the appropriate type and save it against the ApplicationForm.

### Update Work Experience

Find records:

```ruby
# For paid experience
experience = ApplicationForm.find_by(support_reference: _reference_string).application_work_experiences

# For unpaid experience and volunteering:
experience = ApplicationForm.find_by(support_reference: _reference_string).application_volunteering_experiences
```

Update:

```ruby
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
ApplicationQualification.find(_id).update!(grade: 'D', audit_comment: 'Updating grade following a support request, ticket ZENDESK-LINK')
```

**Change start and graduation date**

```ruby
ApplicationQualification.find(_id).update!(start_year: '2011', award_year: '2014', audit_comment: 'Updating an application after a user requested a change, ticket ZENDESK-LINK'
```

## Personal statement

### Update personal statement

The personal statement is split into database fields:

- `becoming_a_teacher` - Why do you want to be a teacher? (‘Vocation' in support)
- `subject_knowledge` - What do you know about the subject you want to teach?

Make sure you know which part you are amending. Add `\r\n\r\n` for carriage return.

```ruby
ApplicationForm.find(_id).update!(becoming_a_teacher: 'new text', subject_knowledge: 'new_text', audit_comment: 'Updating grade following a support request, ticket ZENDESK-LINK')
```

## Courses and course locations

### Changing a course or course location

A provider may request that a candidate is placed on a different course, or a different site. You should make the change by manually executing the `SupportInterface::ChangeApplicationChoiceCourseOption` service to ensure that all required changes take place and  that the application is in a supported state.

If the provider specifies an alternative course but not a site, you should reuse the site code of the existing course. Similarly you should also use the study mode of the existing course unless otherwise specified. In case a site's name was specified but not the site code, you can identify the code by navigating through the support interface to the course's vacancies tab where you can find the site code printed after the course name.

```ruby
SupportInterface::ChangeApplicationChoiceCourseOption.new(application_choice_id: _application_choice_id_,
                                                          provider_id: _provider_id_,
                                                          course_code: _course_code_,
                                                          study_mode: _study_mode_,
                                                          site_code: _site_code_,
                                                          audit_comment: audit_comment).call
```

## Offers

### Make or change offer

If the current application status is `awaiting_provider_decision` use MakeAnOffer service.

If the current application status is `offer` use ChangeOffer service.

### Change offer conditions

This is possible via the support UI.

### Revert an application choice to pending_conditions

This can be requested if a provider accidentally marks an application as conditions not met.

```ruby
a = ApplicationForm.find_by!(support_reference:'$REF')
a.application_choices.select(&:conditions_not_met?).first.update!(status: :pending_conditions, conditions_not_met_at: nil, audit_comment: 'Support request following provider accidentally marking them as conditions_not_met.')
```

### Revert a rejection

Providers may need to revert a rejection so that they can offer a different course or if it was done in error.

If less than five working days have passed since the application has been submitted, then the rejection can be reverted via the
Support UI when viewing the application choice.

If a candidate has had a course rejected in error but wishes to replace their course option with another offered by a _different_ provider,
then following reverting the rejection via the Support UI, you will need to [withdraw the course option via the console](#change-providercourse),
before adding a new course choice via the Support UI.

### Revert a withdrawn offer

This must be done manually via the console.

### Revert a candidate withdrawn application

If a candidate accidentally withdraws their application, it can be reverted via the Support UI

### Accept offer declined by default

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

## Provider users and permissions

### Provider login issues

**Your account is not ready**

Advise the support agent to ask the user to try logging into Manage in the incognito window and ensure correct DfE credentials are used i.e. email registered by Manage as users can have this problem if they have multiple DfE Signin accounts.

**Page not found**

Instruct user to sign out of DFE sign in and log into Apply again from the browser (rather than the email link)

**Your email address is not recognised**

This can be an issue if a user has an old deactivated DfE SignIn account and therefore the wrong DfE SignIn token is associated with their account. To fix it update dfe_sign_in_token.

### Edit relationship permissions

This is possible via the Support UI

`https://www.apply-for-teacher-training.service.gov.uk/support/providers/$ID/relationships`

### Add users in bulk

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

### Disable notifications for an HEI's users and all users at SDs for which they are the sole accredited body

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

## Publish sandbox

### Add users

To help test the Vendor API integrations in Sandbox, Providers will request they be added to the Publish Sandbox, where they can add test courses.

Get access to the `bat-prod` space on cloud foundry.

Target the space using this:

`$ cf target -s bat-prod`

Set your role as a space developer using the command below

`$ cf set-space-role email@email.com dfe bat-prod SpaceDeveloper`

You can now ssh into the sandbox env

`$ cf ssh teacher-training-api-sandbox`

Once you're in, `$ cd /app`

You can now create a csv which will be used when the rake tasks run.

There are two rake tasks, which either import new users, or new providers. You can name the csv however you want, as long as you refer to it in the rake call

`$ /usr/local/bin/bundle exec rake sandbox:create_providers['./providers.csv']`

`$ /usr/local/bin/bundle exec rake sandbox:import_users['./users.csv']`

You'll need a csv for both, with the format specified in the tasks `lib/tasks/sandbox.rake`:

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

`$ /usr/local/bin/bundle exec rails c`

To see if a provider name exists
```
=> Provider.where(provider_name: "University of BAT")
```

Adding a new provider involves setting the provider name and code - I found these by going onto the [apply sandbox](https://sandbox.apply-for-teacher-training.service.gov.uk/support/providers?onboarding_stages%5B%5D=synced&onboarding_stages%5B%5D=dsa_signed), and looking for the required provider. This had the exact name and code.

## Candidate login issues

**Sorry, but there is a problem with the service**

Check logs in Kibana. If there is a 422 Unprocessable Entity response for this user, advise the support agent to go back to the candidate with:

You are experiencing the problem because your browser is storing some old data. We would suggest closing all the tabs, which have Apply service open and clicking the link again: https://www.apply-for-teacher-training.service.gov.uk/candidate/account
If this problem persists please get in touch and we will investigate further.
