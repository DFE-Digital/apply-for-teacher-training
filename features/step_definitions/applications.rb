Given(/(an|the) application in "(.*)" state/) do |_, orginal_application_state|
  if @application
    @application.update(state: orginal_application_state.gsub(' ', '_'))
  else
    @application = CandidateApplication.create!(state: orginal_application_state.gsub(' ', '_'))
  end
end

Given('the following application exists:') do |table|
  table.hashes.each do |row|
    attributes = {}
    attributes[:submitted_at] = DateTime.parse(row['submitted at']) if row['submitted at'].present?
    attributes[:state] = row['status'].gsub(' ', '_') if row['status'].present?

    if row['choice'].present?
      provider_code, course_code = row['choice'].split('/')
      course = Provider
                 .find_by!(code: provider_code)
                 .courses
                 .find_by!(course_code: course_code)
      attributes[:course_choice] = CourseChoice.new(
        course: course,
        training_location: course.training_locations.sample,
      )
    end

    @application = CandidateApplication.create!(attributes)
  end
  pending('Need to deal with offer expiry time assignments')
end

Given('the application stages are set up as follows:') do |table|
  table.hashes.each do |row|
    stage_class = (row['type'] + ' stage').gsub(' ', '_').classify.constantize
    stage_class.create!(
      simultaneous_applications_limit: row['simultaneous applications limit'],
      from_time: DateTime.parse(row['start time']),
      to_time: DateTime.parse(row['end time']),
    )
  end
end

Given('the expiry time on the offer is {string}') do |_offer_expiry_timestamp|
  pending # Write code here that turns the phrase above into concrete actions
end

Given('the candidate has submitted application forms with the following choices:') do |_table|
  # table is a Cucumber::MultilineArgument::DataTable
  pending # Write code here that turns the phrase above into concrete actions
end

Given('a candidate with no submitted application forms in the current recruitment cycle') do
  @candidate = FactoryBot.create(:candidate)
end

When(/^the (\w+) (cannot take|takes) action "([\w\s]+)"$/) do |actor, nil_or_cannot, action|
  command_name = (action.gsub(' ', '_') + '!').to_sym
  if nil_or_cannot == 'cannot take'
    expect { @application.send(command_name, actor) }.to raise_error(Exception)
  else
    @application.send(command_name, actor)
  end
end

When('an application is submitted at {string}') do |timestamp|
  @application = CandidateApplication.create!
  Timecop.freeze(DateTime.parse(timestamp)) do
    @application.submit('candidate')
  end
end

When('the automatic process for rejecting applications is run at {string}') do |current_time|
  Timecop.freeze(DateTime.parse(current_time)) do
    CandidateApplication.reject_applications_with_expired_rbd_times
  end
end

When(/the candidate tries to submit (.*) applications to (\d) different courses at (.*)/) do |_stage, _number_of_courses, _time|
  pending # Write code here that turns the phrase above into concrete actions
end

When(/the provider with code "(.*)" amends a condition at (.*)/) do |_provider_code, _timestamp|
  pending # Write code here that turns the phrase above into concrete actions
end

When('the new expiry time on the offer is {string}') do |_new_offer_expiry_timestamp|
  pending # Write code here that turns the phrase above into concrete actions
end

When(/the candidate creates a new application form on (.*)/) do |date_string|
  Timecop.freeze(Date.parse(date_string)) do
    @candidate.application_forms.create!
  end
end

Then('the new application state is {string}') do |new_application_state|
  expect(@application.reload.state).to eq(new_application_state.gsub(' ', '_'))
end

Then("the application's RBD time is {string}") do |timestamp|
  expect(@application.rejected_by_default_at).to eq(DateTime.parse(timestamp))
end

Then(/a provider with code "(.*)" is able to (add conditions|amend conditions): "(.*)"/) do |provider_code, event_string, yes_or_no|
  command_name = (event_string.gsub(' ', '_') + '!').to_sym
  if yes_or_no == 'Y'
    @application.send(command_name, "provider (#{provider_code})", provider_code)
    expect(@application.state).to eq('conditional_offer')
  else
    expect {
      @application.send(command_name, "provider (#{provider_code})", provider_code)
    }.to raise_error(AASM::InvalidTransition)
  end
end

Then(/the most recent application form is at stage (.*)/) do |stage|
  expect(@candidate.most_recent_form.application_stage.to_s).to eq(stage)
end

Then(/the candidate's application to courses (.*?) at (.*) is (.*)/) do |comma_separated_courses, application_time, valid_or_not|
  form = @candidate.most_recent_form

  comma_separated_courses.split(", ").each do |course_string|
    provider_code, course_code = course_string.split('/')
    provider = Provider.find_by!(code: provider_code)
    course = Course.find_by!(provider: provider, course_code: course_code)
    form.add_course_choice(
      CourseChoice.where(
        course: course,
        training_location: course.training_locations.sample,
      ).first_or_create!
    )
  end

  Timecop.freeze(DateTime.parse(application_time)) do
    expect(form.submit).to (valid_or_not == 'valid' ? be_truthy : be_falsey)
  end
end
