Given(/an application choice has "(.*)" status/) do |orginal_application_status|
  @application_choice = FactoryBot.create(:application_choice, status: orginal_application_status.gsub(' ', '_'))
end

Given('the candidate has specified {string} and {string} as referees') do |_referee1_email, _referee2_email|
  pending
end

When(/^the (\w+) takes action "([\w\s]+)"$/) do |_actor, action|
  command_name = (action.gsub(' ', '_') + '!').to_sym
  ApplicationStateChange.new(@application_choice).send(command_name)
end

When('{string} provides a reference') do |_referee_email|
  pending
end

Then('the new application choice status is {string}') do |new_application_status|
  expect(@application_choice.reload.status).to eq(new_application_status.gsub(' ', '_'))
end
