require 'cucumber/rspec/doubles'

Given(/an application choice has "(.*)" status/) do |original_application_status|
  application_form = FactoryBot.create(:application_form)
  @application_choice = FactoryBot.create(
    :application_choice,
    application_form: application_form,
    status: original_application_status.parameterize(separator: '_'),
  )
end

Given('the candidate has specified {string} and {string} as referees') do |referee1_email, referee2_email|
  @application_choice.application_form.references.map(&:delete)
  FactoryBot.create(:reference, :unsubmitted,
                    email_address: referee1_email,
                    application_form: @application_choice.application_form)
  FactoryBot.create(:reference, :unsubmitted,
                    email_address: referee2_email,
                    application_form: @application_choice.application_form)
end

Given('a {int} working day time limit on {string}') do |limit, rule|
  allow(TimeLimitConfig).to receive(:limits_for).with(rule.to_sym).and_return(
    [
      TimeLimitConfig::Rule.new(nil, nil, limit),
    ],
  )
end

Given('its RBD time is set to {string}') do |time_string|
  @application_choice.update(reject_by_default_at: DateTime.parse(time_string))
end

Given("the time is {int} working days after the form's submission") do |number_of_working_days|
  new_time = number_of_working_days.business_days.since(@application_choice.application_form.submitted_at)
  Timecop.freeze(new_time)
end

Given('the candidate submits a complete application') do
  steps %{
    When an application choice has "unsubmitted" status
    And the candidate has specified "bob@example.com" and "alice@example.com" as referees
    And the candidate submits the application
  }
end

When(/^the candidate submits the application$/) do
  SubmitApplication.new(@application_choice.application_form).call
end

When('{int} referees complete the references') do |number_of_complete_references|
  references = @application_choice.application_form.reload.references[0...number_of_complete_references.to_i]
  references.each do |reference|
    steps %{When "#{reference.email_address}" provides a reference}
  end
end

Then(/^the reject by default time is "(.*?)"$/) do |time|
  expect(@application_choice.reload.reject_by_default_at&.round).to eq Time.zone.parse(time).round
end

When(/^the (\w+) takes action "([\w\s]+)"$/) do |_actor, action|
  command_name = (action.gsub(' ', '_') + '!').to_sym
  ApplicationStateChange.new(@application_choice).send(command_name)
end

When('{string} provides a reference') do |referee_email|
  action = ReceiveReference.new(
    application_form: @application_choice.application_form.reload,
    referee_email: referee_email,
    feedback: Faker::Lorem.paragraphs(number: 2),
  )
  expect(action.save).to be true
end

When(/the (date|time) is "(.*)"/) do |_, date_or_time|
  Timecop.freeze(date_or_time)
end

When('the daily application cron job has run') do
  SendApplicationsToProvider.new.call
  RejectApplicationsByDefault.new.call
end

Then('the new application choice status is {string}') do |new_application_status|
  expect(@application_choice.reload.status).to eq(new_application_status.parameterize(separator: '_'))
end

Then(/the application choice is (flagged|not flagged) as rejected by default/) do |flagged_or_not_flagged|
  expect(@application_choice.reload.rejected_by_default).to be(flagged_or_not_flagged == 'flagged')
end

When(/^the candidate submits a complete application with reference feedback$/) do
  steps %{
    When an application choice has "unsubmitted" status
    And the candidate has specified "bob@example.com" and "alice@example.com" as referees
    And the candidate submits the application
    And "bob@example.com" provides a reference
    And "alice@example.com" provides a reference
  }
end
