# What is inactive?

Inactive is when an application has not been actioned by the Provider for over 30 days.
It is a mix between `awaiting_provider_decision` and `rejected_by_default` and a terminal state.

## How does an application become inactive?
When an application is submitted, we set the `reject_by_default` at

## Why is it considered a Terminal state?
terminal means "unsuccessful". This is `withdrawn`, `rejected`, `declined`, `conditions not met` etc.
terminal also includes successfully `recruited`.

`unsuccessful` is the opposite of `in_progress`.

So `inactive` is considered "not in progress".

There is a limit on the number of open appliations a candidate can have on their application form. When an application becomes `inactive` they can add a new application beyond the limit.

We use `DetectInvariantsDailyCheck#detect_submitted_applications_with_more_than_the_max_unsuccessful_choices` to check for candidates with more than the permitted number of in progress applications.

```ruby
  # app/workers/detect_invariants_daily_check.rb:90

  def detect_submitted_applications_with_more_than_the_max_unsuccessful_choices
    applications_with_too_many_unsuccessful_choices = ApplicationForm
      .joins(:application_choices)
      .where(application_choices: { status: (ApplicationStateChange.unsuccessful - %i[inactive]) })
      .group('application_forms.id')
      .having("count(application_choices) > #{ApplicationForm::MAXIMUM_NUMBER_OF_UNSUCCESSFUL_APPLICATIONS}")
      .sort
```

```ruby
  # app/models/application_form.rb:404

  def in_progress_applications
    application_choices.reject(&:application_unsuccessful?)
  end
```

```ruby
  # app/queries/get_application_progress_data_by_course:21

  def provider_application_choices
    ApplicationChoice.joins(:course)
      .where(status: %i[awaiting_provider_decision interviewing offer pending_conditions recruited inactive])
  end
```

** rename `inactive_since` scope on ApplicationForm **


application_timeline_component doesn't reference inactive status, should it?

In the CandidateInterface, the status tag for inactive is the same colour as `interviewing` and `awaiging_provider_decision`

DetectInvariantsDailyCheck#detect_submitted_applications_with_more_than_the_max_unsuccessful_choices
  This Gets all unsuccessful applications except inactive

Inactive is unsuccessful when:
Inactive is not unsuccessful when:
 - We want to display the references tab in the provider interface on the application choice show action



1. Inactive applications do not count towards the limit of choices a candidate can make on an application form.
2. In the Provider interface and API, the status of inactive is shown as `received`
    a. They are sorted to the top of the application choice index
    b. They do not have a filter on the index
3.
