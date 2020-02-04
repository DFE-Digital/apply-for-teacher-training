require 'rails_helper'

RSpec.describe 'A Provider can log in as a candidate' do
  include CourseOptionHelpers
  include DfESignInHelpers

  scenario 'when viewing an application on non-production environments' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_for_my_provider
    and_my_organisation_has_received_an_application
    and_i_sign_in_to_the_provider_interface

    when_i_visit_that_application_in_the_provider_interface
    and_i_click_on_the_sign_in_button

    then_i_am_redirected_to_the_candidate_interface
    and_i_see_a_flash_message
    and_i_am_logged_in_as_that_candidate
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_am_permitted_to_see_applications_for_my_provider
    @provider = create(:provider, :with_signed_agreement)
    create(:provider_user, providers: [@provider], dfe_sign_in_uid: 'DFE_SIGN_IN_UID')
  end

  def and_my_organisation_has_received_an_application
    course_option = course_option_for_provider_code(provider_code: @provider.code)
    @application_choice = create(:application_choice, status: 'awaiting_provider_decision', course_option: course_option)
    @candidate = @application_choice.application_form.candidate
  end

  def when_i_visit_that_application_in_the_provider_interface
    visit provider_interface_application_choice_path(@application_choice)
  end

  def and_i_click_on_the_sign_in_button
    click_on 'Sign in as this candidate'
  end

  def then_i_am_redirected_to_the_candidate_interface
    expect(page).to have_current_path(candidate_interface_application_form_path)
  end

  def and_i_see_a_flash_message
    expect(page).to have_content('You are now signed in as')
  end

  def and_i_am_logged_in_as_that_candidate
    expect(page).to have_content(@candidate.email_address)
  end
end
