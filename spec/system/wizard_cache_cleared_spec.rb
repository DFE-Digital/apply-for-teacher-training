require 'rails_helper'

RSpec.describe 'Clearing the wizard cache' do
  include CourseOptionHelpers
  include DfESignInHelpers
  include ProviderUserPermissionsHelper

  let(:application_choice) { create(:application_choice, :awaiting_provider_decision, course_option:) }
  let(:course_option) { course_option_for_provider_code(provider_code: 'ABC') }

  before do
    TestSuiteTimeMachine.travel_permanently_to(Time.zone.now)
  end

  # check InterviewsController for configuration
  scenario 'when the user re-enters a wizard the cache is cleared' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_set_up_interviews_for_my_provider
    and_i_sign_in_to_the_provider_interface

    when_i_visit_that_application_in_the_provider_interface
    and_i_click_set_up_an_interview
    and_i_fill_out_the_interview_form(days_in_future: 1, time: '12pm')

    and_i_go_back
    and_i_go_back_again
    then_i_am_on_the_application_page

    when_i_click_set_up_an_interview
    then_i_see_an_empty_interview_form
  end

  # check ReasonsForRejectionController for configuration
  scenario 'on entrypoint checks, when the user re-enters a wizard from a specified entrypoint the cache is cleared' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_make_decisions_for_my_provider
    and_i_sign_in_to_the_provider_interface

    when_i_visit_that_application_in_the_provider_interface
    and_i_click_make_decision

    when_i_choose_to_reject_application
    and_i_select_why_i_am_rejecting_the_application
    and_i_go_back
    and_i_go_back_again
    then_i_am_on_the_decision_page

    when_i_choose_to_reject_application
    then_i_see_a_cleared_reasons_for_rejection_page
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_am_permitted_to_set_up_interviews_for_my_provider
    provider_user_exists_in_apply_database
    permit_set_up_interviews!
  end

  def and_i_am_permitted_to_make_decisions_for_my_provider
    provider_user_exists_in_apply_database
    permit_make_decisions!
  end

  def when_i_visit_that_application_in_the_provider_interface
    visit provider_interface_application_choice_path(application_choice)
  end

  def and_i_click_set_up_an_interview
    click_link_or_button 'Set up interview'
  end

  def and_i_click_make_decision
    click_link_or_button 'Make decision'
  end

  def when_i_choose_to_reject_application
    choose 'Reject application'
    click_link_or_button 'Continue'
  end

  alias_method :when_i_click_set_up_an_interview, :and_i_click_set_up_an_interview

  def and_i_fill_out_the_interview_form(days_in_future:, time:)
    tomorrow = days_in_future.day.from_now
    fill_in 'Day', with: tomorrow.day
    fill_in 'Month', with: tomorrow.month
    fill_in 'Year', with: tomorrow.year

    fill_in 'Start time', with: time

    fill_in 'Address or online meeting details', with: 'N/A'

    click_link_or_button 'Continue'
  end

  def and_i_go_back
    click_link_or_button 'Back'
  end

  alias_method :and_i_go_back_again, :and_i_go_back

  def then_i_am_on_the_application_page
    expect(page).to have_current_path(provider_interface_application_choice_path(application_choice))
  end

  def then_i_see_an_empty_interview_form
    expect(page).to have_content('Set up an interview')

    expect(page.find_field('Day').value).to be_nil
    expect(page.find_field('Month').value).to be_nil
    expect(page.find_field('Year').value).to be_nil
    expect(page.find_field('Start time').value).to be_nil
    expect(page.find_field('Address or online meeting details').value).to be_empty
  end

  def then_i_am_on_the_decision_page
    expect(page).to have_current_path(new_provider_interface_application_choice_decision_path(application_choice))
  end

  def and_i_select_why_i_am_rejecting_the_application
    check 'provider-interface-rejections-wizard-selected-reasons-qualifications-field'
    check 'provider-interface-rejections-wizard-qualifications-selected-reasons-no-maths-gcse-field'
    check 'provider-interface-rejections-wizard-qualifications-selected-reasons-unverified-qualifications-field'
    fill_in 'provider-interface-rejections-wizard-unverified-qualifications-details-field', with: 'We can find no evidence of your GCSEs'

    check 'provider-interface-rejections-wizard-selected-reasons-personal-statement-field'
    check 'provider-interface-rejections-wizard-personal-statement-selected-reasons-quality-of-writing-field'
    fill_in 'provider-interface-rejections-wizard-quality-of-writing-details-field', with: 'We do not accept applications written in morse code'
    check 'provider-interface-rejections-wizard-personal-statement-selected-reasons-personal-statement-other-field'
    fill_in 'provider-interface-rejections-wizard-personal-statement-other-details-field', with: 'This was wayyyyy too personal'

    check 'provider-interface-rejections-wizard-selected-reasons-course-full-field'
    check 'provider-interface-rejections-wizard-course-full-selected-reasons-salary-course-full-field'
    fill_in 'provider-interface-rejections-wizard-salary-course-full-details-field', with: 'Course is full'

    check 'provider-interface-rejections-wizard-selected-reasons-other-field'
    fill_in 'provider-interface-rejections-wizard-other-details-field', with: 'There are so many other reasons why your application was rejected...'

    click_link_or_button t('continue')
  end

  def then_i_see_a_cleared_reasons_for_rejection_page
    click_link_or_button t('continue')

    within '.govuk-error-summary' do
      expect(page).to have_content('There is a problem')
      expect(page).to have_css('.govuk-error-summary__list li', count: 1)
    end
  end
end
