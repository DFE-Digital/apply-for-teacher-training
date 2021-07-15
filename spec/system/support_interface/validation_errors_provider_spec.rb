require 'rails_helper'

RSpec.feature 'Validation errors Provider' do
  include DfESignInHelpers
  include ProviderUserPermissionsHelper
  include CourseOptionHelpers

  let(:application_choice) { create(:application_choice, :awaiting_provider_decision, course_option: course_option) }
  let(:course_option) { course_option_for_provider_code(provider_code: 'ABC') }

  around do |example|
    Timecop.freeze do
      example.run
    end
  end

  scenario 'Review validation errors' do
    given_i_signed_in_as_a_provider_user
    and_i_enter_an_invalid_interview_time

    given_i_am_a_support_user

    when_i_navigate_to_the_validation_errors_page
    then_i_should_see_a_list_of_error_groups

    when_i_click_on_a_group
    then_i_should_see_a_list_of_individual_errors

    when_i_click_on_link_in_breadcrumb_trail
    then_i_should_be_back_on_index_page
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

  def when_i_navigate_to_the_validation_errors_page
    visit support_interface_path
    click_link 'Performance'
    click_link 'Validation errors'
    click_link 'Provider validation errors'
  end

  def then_i_should_see_a_list_of_error_groups
    @validation_error = ValidationError.last
    expect(page).to have_content('Interview wizard: Time')
    expect(page).to have_content('1')
  end

  def when_i_click_on_a_group
    click_on 'Time'
  end

  def then_i_should_see_a_list_of_individual_errors
    expect(page).to have_content(Time.zone.now.to_s(:govuk_date_and_time))
    expect(page).to have_content('Showing errors on the Time field in Interview wizard by all users.')
    expect(page).to have_content('Interview wizard: Time')
    expect(page).to have_content('45pm')
  end

  def when_i_click_on_link_in_breadcrumb_trail
    click_on 'Validation errors'
  end

  def then_i_should_be_back_on_index_page
    expect(page).to have_current_path(support_interface_validation_errors_path)
  end
end
