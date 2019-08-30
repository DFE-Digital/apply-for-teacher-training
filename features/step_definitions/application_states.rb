Given("an application in {string} state") do |orginal_application_state|
  @application = CandidateApplication.new(state: orginal_application_state.gsub(" ", "_"))
end

When(/a (\w+) (.*)/) do |actor, action|
  event_name = action.gsub(" ", "_").to_sym
  begin
    @application.send(event_name, actor)
  rescue AASM::InvalidTransition
  end
end

Then("the new application state is {string}") do |new_application_state|
  expect(@application.state).to eq(new_application_state.gsub(" ", "_"))
end
