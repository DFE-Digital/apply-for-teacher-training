require 'rails_helper'

RSpec.describe 'A Provider viewing an individual application', :with_audited do
  include CourseOptionHelpers
  include DfESignInHelpers
  include ProviderUserPermissionsHelper

  let(:application_choice) { create(:application_choice, :awaiting_provider_decision, course_option:) }
  let(:course_option) { course_option_for_provider_code(provider_code: 'ABC') }

  before do
    TestSuiteTimeMachine.travel_permanently_to(Time.zone.now)
  end

  scenario 'can view, create and cancel interviews' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_for_my_provider
    and_i_am_permitted_to_set_up_interviews_for_my_provider
    and_i_sign_in_to_the_provider_interface

    when_i_visit_that_application_in_the_provider_interface
    and_i_click_set_up_an_interview
    and_i_fill_out_the_interview_form(days_in_future: -1, time: '12pm')
    then_i_see_an_error_message

    and_i_go_back
    then_i_should_be_on_the_application_page

    and_i_click_set_up_an_interview
    and_i_fill_out_the_interview_form(days_in_future: 1, time: '10pm')
    then_i_can_check_the_interview_details(time: '10pm')

    and_i_go_back
    and_i_fill_out_the_interview_form(days_in_future: 1, time: '12pm')
    then_i_can_check_the_interview_details(time: '12pm')
    and_i_click_send_interview_details
    then_i_see_a_success_message
    and_an_interview_has_been_created(1.day.from_now.to_fs(:govuk_date))

    when_i_navigate_to_notes_tab
    and_i_do_not_see_the_set_up_interview_button
    then_i_navigate_back_to_the_interviews_tab

    when_i_set_up_another_interview(days_in_future: 2)
    then_another_interview_has_been_created(2.days.from_now.to_fs(:govuk_date))

    when_i_change_the_interview_details
    and_i_confirm_the_interview_details
    then_i_can_see_the_interview_was_updated

    when_i_click_to_cancel_an_interview
    and_i_do_not_enter_a_cancellation_reason
    then_i_see_a_validation_error

    and_i_go_back
    then_i_should_be_on_the_application_interviews_page

    when_i_click_to_cancel_an_interview
    and_i_enter_a_valid_cancellation_reason
    when_i_confirm_the_cancellation
    i_can_see_the_application_is_still_in_the_interviewing_state
    and_i_can_see_the_second_interview

    when_i_cancel_an_interview
    i_can_see_the_application_is_awaiting_provider_decision
    and_the_interview_tab_is_not_available

    when_i_set_up_another_interview(days_in_future: 4)
    then_another_interview_has_been_created(4.days.from_now.to_fs(:govuk_date))
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_am_permitted_to_see_applications_for_my_provider
    provider_user_exists_in_apply_database
  end

  def and_i_am_permitted_to_set_up_interviews_for_my_provider
    permit_set_up_interviews!
  end

  def when_i_visit_that_application_in_the_provider_interface
    visit provider_interface_application_choice_path(application_choice)
  end

  def and_i_click_set_up_an_interview
    click_link 'Set up interview'
  end

  def when_i_set_up_another_interview(days_in_future:)
    and_i_click_set_up_an_interview
    and_i_fill_out_the_interview_form(days_in_future:, time: '7pm')
    and_i_click_send_interview_details
    then_i_see_a_success_message
  end

  def and_i_fill_out_the_interview_form(days_in_future:, time:)
    tomorrow = days_in_future.day.from_now
    fill_in 'Day', with: tomorrow.day
    fill_in 'Month', with: tomorrow.month
    fill_in 'Year', with: tomorrow.year

    fill_in 'Start time', with: time

    fill_in 'Address or online meeting details', with: 'N/A'

    click_button 'Continue'
  end

  def then_i_can_check_the_interview_details(time:)
    within all('.govuk-summary-list__row dd p')[1] do
      expect(page).to have_content(time)
    end
  end

  def and_i_click_send_interview_details
    click_button 'Send interview details'
  end

  def and_i_go_back
    click_link 'Back'
  end

  def then_i_see_an_error_message
    expect(page).to have_content 'There is a problem'
  end

  def then_i_should_be_on_the_application_page
    expect(page).to have_current_path(provider_interface_application_choice_path(application_choice))
  end

  def then_i_should_be_on_the_application_interviews_page
    expect(page).to have_current_path(provider_interface_application_choice_interviews_path(application_choice))
  end

  def then_i_see_a_success_message
    expect(page).to have_content 'Interview set up'
  end

  def and_an_interview_has_been_created(date)
    within('.app-interviews') do
      expect(page).to have_content(date)
    end
  end

  alias_method :then_another_interview_has_been_created, :and_an_interview_has_been_created

  def when_i_navigate_to_notes_tab
    click_link 'Notes'
  end

  def and_i_do_not_see_the_set_up_interview_button
    expect(page).not_to have_button 'Set up interview'
  end

  def then_i_navigate_back_to_the_interviews_tab
    click_link 'Interviews'
  end

  def when_i_change_the_interview_details
    click_link 'Change details', match: :first

    expect(page).to have_field('Day', with: 1.day.from_now.day)
    expect(page).to have_field('Month', with: 1.day.from_now.month)
    expect(page).to have_field('Year', with: 1.day.from_now.year)
    expect(page).to have_field('Start time', with: '12:00pm')
    expect(page).to have_field('Address or online meeting details', with: 'N/A')
    expect(page).to have_field('Additional details (optional)', with: '')

    fill_in 'Day', with: 2.days.from_now.day
    fill_in 'Month', with: 2.days.from_now.month
    fill_in 'Year', with: 2.days.from_now.year
    fill_in 'Start time', with: '10am'

    fill_in 'Address or online meeting details', with: 'Zoom meeting'
    fill_in 'Additional details (optional)', with: 'Business casual'

    click_button 'Continue'
  end

  def and_i_confirm_the_interview_details
    expect(page).to have_content('Check and send new interview details')
    expect(page).to have_content("Date\n#{2.days.from_now.to_fs(:govuk_date)}")
    expect(page).to have_content("Start time\n10am")
    expect(page).to have_content("Address or online meeting details\nZoom meeting")
    expect(page).to have_content("Additional details\nBusiness casual")

    click_link 'Change', match: :first

    fill_in 'Additional details (optional)', with: 'Business casual, first impressions are important.'

    click_button 'Continue'

    expect(page).to have_content("Additional details\nBusiness casual, first impressions are important")

    click_button 'Send new interview details'
  end

  def then_i_can_see_the_interview_was_updated
    expect(page).to have_content('Interview changed')
    expect(page).to have_content("#{2.days.from_now.to_fs(:govuk_date)} at 10am")
    expect(page).to have_content("Address or online meeting details\nZoom meeting")
    expect(page).to have_content("Additional details\nBusiness casual, first impressions are important")
  end

  def when_i_click_to_cancel_an_interview
    first(:link, 'Cancel').click
  end

  def and_i_do_not_enter_a_cancellation_reason
    click_button 'Continue'
  end

  def then_i_see_a_validation_error
    expect(page).to have_content 'Enter reason for cancelling interview'
  end

  def when_i_enter_a_valid_cancellation_reason
    fill_in 'provider_interface_cancel_interview_wizard[cancellation_reason]', with: 'A cancellation reason'
    click_button 'Continue'
  end

  alias_method :and_i_enter_a_valid_cancellation_reason, :when_i_enter_a_valid_cancellation_reason

  def then_i_see_the_check_page_with_working_edit_links
    expect(page).to have_content 'A cancellation reason'
    expect(page).to have_content 'Change'

    click_link 'Change'
    expect(page).to have_field('provider_interface_cancel_interview_wizard[cancellation_reason]', with: 'A cancellation reason')
    click_button 'Continue'
  end

  def when_i_confirm_the_cancellation
    click_button 'Send cancellation'
    expect(page).to have_content('Interview cancelled')
  end

  def when_i_cancel_an_interview
    when_i_click_to_cancel_an_interview
    when_i_enter_a_valid_cancellation_reason
    when_i_confirm_the_cancellation
  end

  def i_can_see_the_application_is_still_in_the_interviewing_state
    expect(page).to have_content('Interviewing')
  end

  def and_i_can_see_the_second_interview
    visit provider_interface_application_choice_interviews_path(application_choice)

    expect(page).to have_content('Upcoming interviews')
    expect(page).to have_css('.app-interviews__interview')
  end

  def i_can_see_the_application_is_awaiting_provider_decision
    expect(page).to have_content('Received')
  end

  def and_the_interview_tab_is_not_available
    within '.app-tab-navigation__list' do
      expect(page).not_to have_content('Interviews')
    end
  end
end
