Given(/(an|the) application in "(.*)" state/) do |_, orginal_application_state|
  if @application
    @application.update(state: orginal_application_state.gsub(' ', '_'))
  else
    @application = CandidateApplication.create!(state: orginal_application_state.gsub(' ', '_'))
  end
end

When(/^a (\w+) ([\w\s]+)$/) do |actor, action|
  event_name = action.gsub(' ', '_').to_sym
  begin
    @application.aasm.fire!(event_name, actor)
  rescue AASM::InvalidTransition # rubocop:disable Lint/HandleExceptions
  end
end

When('an application is submitted at {string}') do |timestamp|
  @application = CandidateApplication.create!
  Timecop.freeze(DateTime.parse(timestamp)) do
    @application.submit('candidate')
  end
end

Then('the new application state is {string}') do |new_application_state|
  expect(@application.reload.state).to eq(new_application_state.gsub(' ', '_'))
end

Then("the application's RBD time is {string}") do |timestamp|
  expect(@application.rejected_by_default_at).to eq(DateTime.parse(timestamp))
end

When('the automatic process for rejecting applications is run at {string}') do |current_time|
  Timecop.freeze(DateTime.parse(current_time)) do
    CandidateApplication.reject_applications_with_expired_rbd_times
  end
end

Then('a provider with code {string} is able to add conditions: {string}') do |provider_code, can_add_conditions|
  if can_add_conditions == 'Y'
    @application.add_conditions('provider', provider_code)
    expect(@application.state).to eq('offer_made')
  else
    expect {
      @application.add_conditions('provider', provider_code)
    }.to raise_error(AASM::InvalidTransition)
  end
end

Given('the application stages are set up as follows:') do |_table|
  # table is a Cucumber::MultilineArgument::DataTable
  pending # Write code here that turns the phrase above into concrete actions
end

When(/the candidate tries to submit (.*) applications to (\d) different courses at (.*)/) do |_stage, _number_of_courses, _time|
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/the candidate's (.*) batch to course[s]? (.*) at (.*) is (.*)/) do |_stage, _courses, _time, _valid_or_invalid|
  pending # Write code here that turns the phrase above into concrete actions
end

Given(/the candidate has made (.*) (Apply \d) applications in the current recruitment cycle/) do |no_or_number, _stage|
  _number_of_previous_applications = no_or_number == 'no' ? 0 : no_number
  pending # Write code here that turns the phrase above into concrete actions
end
