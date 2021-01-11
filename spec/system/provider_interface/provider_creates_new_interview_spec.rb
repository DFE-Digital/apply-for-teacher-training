require 'rails_helper'

RSpec.feature 'Create Interview' do
  include CourseOptionHelpers
  include DfESignInHelpers
  include ProviderUserPermissionsHelper

  scenario 'provider creates a new interview' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_a_submitted_application_choice_exists_for_my_provider
    and_i_am_permitted_to_make_decisions_on_applications_for_my_provider
    and_i_sign_in_to_the_provider_interface

    when_i_go_to_the_application_page
    and_i_click_set_up_an_interview
    and_i_fill_out_the_interview_form
    and_i_click_send_interview_details

    then_i_see_a_success_message
    and_an_interview_has_been_created
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_a_submitted_application_choice_exists_for_my_provider
    course_option = course_option_for_provider_code(provider_code: 'ABC')
    @application_submitted = create(:submitted_application_choice, course_option: course_option, application_form: create(:completed_application_form, first_name: 'Alice', last_name: 'Wunder'))
  end

  def and_i_am_permitted_to_make_decisions_on_applications_for_my_provider
    provider_user_exists_in_apply_database
    permit_make_decisions!
  end

  def when_i_go_to_the_application_page
    click_on 'Alice Wunder'
  end

  def and_i_click_set_up_an_interview
    click_on 'Set up interview'
  end

  def and_i_fill_out_the_interview_form
    tomorrow = 1.day.from_now
    fill_in 'Day', with: tomorrow.day
    fill_in 'Month', with: tomorrow.month
    fill_in 'Year', with: tomorrow.year

    fill_in 'Time', with: '12pm'

    fill_in 'Address or online meeting details', with: 'N/A'

    click_on 'Continue'
  end

  def and_i_click_send_interview_details
    click_on 'Send interview details'
  end

  def then_i_see_a_success_message
    expect(page).to have_content 'Interview set up'
  end

  def and_an_interview_has_been_created
    expect(@application_submitted.interviews).not_to be_empty
  end
end
