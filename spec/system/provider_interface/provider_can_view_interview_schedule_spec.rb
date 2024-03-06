require 'rails_helper'

RSpec.describe 'A Provider user' do
  include DfESignInHelpers

  let(:provider_user) { create(:provider_user, :with_dfe_sign_in) }
  let(:provider) { provider_user.providers.first }
  let(:application_form) { create(:application_form) }
  let(:course) { create(:course, :open, provider:) }

  before do
    TestSuiteTimeMachine.travel_permanently_to(Time.zone.now.midday)
  end

  scenario 'can view all present and past interviews scheduled for their provider' do
    given_i_am_a_provider_user
    and_i_sign_in_to_the_provider_interface

    when_i_visit_the_provider_interface
    and_i_click_interview_schedule
    then_i_see_no_upcoming_interviews

    and_i_click_past_interviews
    then_i_see_no_past_interviews

    given_there_are_past_and_present_interviews
    when_i_visit_the_provider_interface

    and_i_click_interview_schedule
    then_i_see_the_upcoming_interviews

    and_i_click_past_interviews
    then_i_see_the_past_interviews

    and_i_can_verify_that_the_correct_information_is_presented
  end

  def given_i_am_a_provider_user
    user_exists_in_dfe_sign_in(email_address: provider_user.email_address)
  end

  def and_i_sign_in_to_the_provider_interface
    provider_signs_in_using_dfe_sign_in
  end

  def when_i_visit_the_provider_interface
    visit provider_interface_applications_path
  end

  def given_there_are_past_and_present_interviews
    application_choices = 4.times.map do
      create(:application_choice,
             :awaiting_provider_decision,
             course_option: create(:course_option, course: create(:course, provider:)),
             application_form:)
    end

    @interviews = application_choices[0...3].map do |application_choice|
      create(:interview,
             :future_date_and_time,
             application_choice:)
    end

    @application_choice = application_choices[3]

    # Both of these interviews should appear as upcoming, since they are arranged for today
    @interviews << create(:interview, application_choice: @application_choice, date_and_time: 2.hours.from_now)
    @interviews << create(:interview, application_choice: @application_choice, date_and_time: 2.hours.ago)

    @past_interviews = application_choices.map do |application_choice|
      create(:interview,
             :past_date_and_time,
             application_choice:)
    end
  end

  def and_i_click_interview_schedule
    click_link_or_button 'Interview schedule'
  end

  def then_i_see_the_upcoming_interviews
    within '.app-interviews' do
      expect(page.assert_selector('.app-interview-card', count: @interviews.count)).to be(true)
    end
  end

  def then_i_see_no_upcoming_interviews
    expect(page).to have_content('No upcoming interviews')
  end

  def and_i_click_past_interviews
    click_link_or_button 'Past interviews'
  end

  def then_i_see_the_past_interviews
    within '.app-interviews' do
      expect(page.assert_selector('.app-interview-card', count: @past_interviews.count)).to be(true)
    end
  end

  def then_i_see_no_past_interviews
    expect(page).to have_content('No past interviews')
  end

  def and_i_can_verify_that_the_correct_information_is_presented
    click_link_or_button 'Upcoming interviews'
    expect(page).to have_content("Today (#{@interviews.last.date_and_time.to_fs(:govuk_date)})")
    within(:xpath, "////div[@class='app-interview-card'][1]") do
      expect(page).to have_content(@application_choice.course.name)
      expect(page).to have_content(@application_choice.course_option.site.name)
    end

    page.first(:css, '.app-interview-card__time:first a', text: @interviews.last.date_and_time.to_fs(:govuk_time)).click
    expect(page).to have_content(@interviews.last.date_and_time.to_fs(:govuk_date_and_time))
  end
end
