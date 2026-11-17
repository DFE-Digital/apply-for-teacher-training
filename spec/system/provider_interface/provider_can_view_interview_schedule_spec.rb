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

  scenario 'can filter upcoming interviews by subject and course' do
    given_i_am_a_provider_user
    and_there_are_interviews_for_different_subjects
    and_i_sign_in_to_the_provider_interface

    when_i_visit_the_provider_interface
    and_i_click_interview_schedule
    then_i_see_the_upcoming_maths_and_history_interviews

    when_i_filter_by_the_mathematics_subject
    then_i_see_only_the_upcoming_maths_interview

    when_i_clear_the_filters
    and_i_filter_by_the_history_course
    then_i_see_only_the_upcoming_history_interview
  end

  scenario 'can filter past interviews by subject and course' do
    given_i_am_a_provider_user
    and_there_are_interviews_for_different_subjects
    and_i_sign_in_to_the_provider_interface

    when_i_visit_the_provider_interface
    and_i_click_interview_schedule
    and_i_click_past_interviews
    then_i_see_the_past_maths_and_history_interviews

    when_i_filter_by_the_mathematics_subject
    then_i_see_only_the_past_maths_interview

    when_i_clear_the_filters
    and_i_filter_by_the_history_course
    then_i_see_only_the_past_history_interview
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

  def and_there_are_interviews_for_different_subjects
    @maths_course = create(:course, provider:, name: 'Maths course', subjects: [create(:subject, name: 'Mathematics')])
    @history_course = create(:course, provider:, name: 'History course', subjects: [create(:subject, name: 'History')])

    maths_choice = create(:application_choice, :awaiting_provider_decision, course_option: create(:course_option, course: @maths_course))
    history_choice = create(:application_choice, :awaiting_provider_decision, course_option: create(:course_option, course: @history_course))

    create(:interview, :future_date_and_time, application_choice: maths_choice)
    create(:interview, :future_date_and_time, application_choice: history_choice)
    create(:interview, :past_date_and_time, application_choice: maths_choice)
    create(:interview, :past_date_and_time, application_choice: history_choice)
  end

  def when_i_filter_by_the_mathematics_subject
    check 'Mathematics'
    click_link_or_button 'Apply filters', match: :first
  end

  def and_i_filter_by_the_history_course
    check @history_course.name_and_code
    click_link_or_button 'Apply filters', match: :first
  end

  def when_i_clear_the_filters
    click_link_or_button 'Clear filters'
  end

  def then_i_see_the_upcoming_maths_and_history_interviews
    then_i_see_interviews_for(@maths_course, @history_course)
  end

  def then_i_see_only_the_upcoming_maths_interview
    then_i_see_interviews_for(@maths_course)
  end

  def then_i_see_only_the_upcoming_history_interview
    then_i_see_interviews_for(@history_course)
  end

  def then_i_see_the_past_maths_and_history_interviews
    expect(page).to have_current_path(past_provider_interface_interview_schedule_path, ignore_query: true)
    then_i_see_interviews_for(@maths_course, @history_course)
  end

  def then_i_see_only_the_past_maths_interview
    expect(page).to have_current_path(past_provider_interface_interview_schedule_path, ignore_query: true)
    then_i_see_interviews_for(@maths_course)
  end

  def then_i_see_only_the_past_history_interview
    expect(page).to have_current_path(past_provider_interface_interview_schedule_path, ignore_query: true)
    then_i_see_interviews_for(@history_course)
  end

  def then_i_see_interviews_for(*courses)
    within '.app-interviews' do
      expect(page).to have_css('.app-interview-card', count: courses.count)
      courses.each { |course| expect(page).to have_text(course.name) }
      ([@maths_course, @history_course] - courses).each { |course| expect(page).to have_no_text(course.name) }
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
    expect(page).to have_text('There are no results for the selected filters.')
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
    expect(page).to have_current_path(past_provider_interface_interview_schedule_path)
    expect(page).to have_text('There are no results for the selected filters.')
  end

  def and_i_can_verify_that_the_correct_information_is_presented
    click_link_or_button 'Upcoming interviews'
    expect(page).to have_text("Today (#{@interviews.last.date_and_time.to_fs(:govuk_date)})")
    within(:xpath, "////div[@class='app-interview-card'][1]") do
      expect(page).to have_text(@application_choice.course.name)
      expect(page).to have_text(@application_choice.course_option.site.name)
    end

    page.first(:css, '.app-interview-card__time:first a', text: @interviews.last.date_and_time.to_fs(:govuk_time)).click
    expect(page).to have_text(@interviews.last.date_and_time.to_fs(:govuk_date_and_time))
  end
end
