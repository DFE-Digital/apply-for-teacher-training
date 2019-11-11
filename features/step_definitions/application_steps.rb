Given(/an application choice has "(.*)" status/) do |original_application_status|
  application_form = FactoryBot.create(:application_form)
  @application_choice = FactoryBot.create(
    :application_choice,
    :single,
    application_form: application_form,
    status: original_application_status.gsub(' ', '_'),
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

When(/^the candidate submits the application$/) do
  SubmitApplication.new(@application_choice.application_form).call
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
  expect(action.save).to be_truthy
end

When('the date is {string}') do |date|
  Timecop.freeze(date)
end

When('the daily application cron job has run') do
  SendApplicationsToProvider.new.call
end

Then('the new application choice status is {string}') do |new_application_status|
  expect(@application_choice.reload.status).to eq(new_application_status.parameterize(separator: '_'))
end
