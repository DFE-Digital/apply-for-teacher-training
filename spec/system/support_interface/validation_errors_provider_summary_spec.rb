require 'rails_helper'

RSpec.feature 'Validation errors provider summary' do
  include DfESignInHelpers
  include ProviderUserPermissionsHelper
  include CourseOptionHelpers

  let(:application_choice) { create(:application_choice, :awaiting_provider_decision, course_option: course_option) }
  let(:course_option) { course_option_for_provider_code(provider_code: 'ABC') }

  scenario 'Review validation error summary' do
    given_i_signed_in_as_a_provider_user
    and_i_enter_an_invalid_interview_time

    given_i_am_a_support_user

    when_i_navigate_to_the_validation_errors_summary_page
    then_i_should_see_numbers_for_the_past_week_month_and_all_time

    when_i_click_on_link_to_drilldown_contact_details_form_errors
    then_i_should_see_errors_for_contact_details_form_only
  end

  def given_i_signed_in_as_a_provider_user
    provider_exists_in_dfe_sign_in
    provider_user_exists_in_apply_database
    permit_make_decisions!
    permit_set_up_interviews!
    provider_signs_in_using_dfe_sign_in
    visit provider_interface_application_choice_path(application_choice)
  end

  def and_i_enter_an_invalid_interview_time
    click_on 'Set up interview'

    tomorrow = 1.day.from_now
    fill_in 'Day', with: tomorrow.day
    fill_in 'Month', with: tomorrow.month
    fill_in 'Year', with: tomorrow.year

    fill_in 'Time', with: '45pm'

    fill_in 'Address or online meeting details', with: 'We will let you know'

    click_on 'Continue'
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def when_i_navigate_to_the_validation_errors_summary_page
    visit support_interface_path
    click_link 'Performance'
    click_link 'Validation errors'
    click_link 'Provider validation errors'
    click_link 'Validation error summary'
  end

  def then_i_should_see_numbers_for_the_past_week_month_and_all_time
    expect(find('table').all('tr')[2].text).to eq 'Interview wizard Time 1 1 1 1 1 1'
  end

  def when_i_click_on_link_to_drilldown_contact_details_form_errors
    click_link 'Interview wizard'
  end

  def then_i_should_see_errors_for_contact_details_form_only
    expect(page).to have_current_path(
      support_interface_validation_errors_provider_search_path(form_object: 'ProviderInterface::InterviewWizard'),
    )
  end
end
