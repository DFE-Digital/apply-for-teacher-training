require 'rails_helper'

RSpec.feature 'See applications' do
  include CourseOptionHelpers
  include DfESignInHelpers

  scenario 'Provider visits applications when there are none' do
    given_i_am_a_provider_user_authenticated_with_dfe_sign_in
    and_my_training_provider_exists
    and_another_organisation_has_applications

    when_i_have_been_assigned_to_my_training_provider
    and_i_sign_in_to_the_provider_interface

    then_i_should_see_no_applications
  end

  scenario 'Provider visits application page' do
    given_i_am_a_provider_user_authenticated_with_dfe_sign_in
    and_my_organisation_has_applications

    and_i_sign_in_to_the_provider_interface
    then_i_should_see_the_account_creation_in_progress_page

    when_my_apply_account_has_been_created
    and_i_sign_in_to_the_provider_interface
    then_i_should_see_the_applications_from_my_organisation

    when_i_click_on_an_application
    then_i_should_be_on_the_application_view_page
  end

  def when_my_apply_account_has_been_created
    provider_user = provider_user_exists_in_apply_database
    create(:provider, :with_signed_agreement, code: 'ABC', provider_users: [provider_user])
  end

  def and_my_training_provider_exists
    create(:provider, :with_signed_agreement, code: 'ABC')
  end

  def given_i_am_a_provider_user_authenticated_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
    provider_signs_in_using_dfe_sign_in
  end

  def then_i_should_see_the_account_creation_in_progress_page
    expect(page).to have_content('Your account is not ready yet')
  end

  def when_i_have_been_assigned_to_my_training_provider
    provider_user_exists_in_apply_database
  end

  def and_my_organisation_has_applications
    course_option = course_option_for_provider_code(provider_code: 'ABC')

    @my_provider_choice1  = create(:submitted_application_choice, status: 'awaiting_provider_decision', course_option: course_option)
    @my_provider_choice2  = create(:submitted_application_choice, status: 'awaiting_provider_decision', course_option: course_option)
  end

  def and_another_organisation_has_applications
    other_course_option = course_option_for_provider_code(provider_code: 'ANOTHER_ORG')

    @other_provider_choice = create(:submitted_application_choice, status: 'awaiting_provider_decision', course_option: other_course_option)
  end

  def and_i_visit_the_provider_page
    visit provider_interface_path
  end

  alias :when_i_visit_the_provider_page :and_i_visit_the_provider_page

  def then_i_should_see_the_applications_from_my_organisation
    expect(page).to have_content @my_provider_choice1.application_form.first_name
    expect(page).to have_content @my_provider_choice2.application_form.first_name
  end

  def then_i_should_see_no_applications
    expect(page).to have_content 'You haven’t received any applications'
    expect(page).not_to have_selector('.govuk-table')
  end

  def but_not_the_applications_from_other_providers
    expect(page).not_to have_content @other_provider_choice.application_form.first_name
  end

  def when_i_click_on_an_application
    click_on @my_provider_choice1.application_form.first_name
  end

  def then_i_should_be_on_the_application_view_page
    expect(page).to have_content 'Application for'
    expect(page).to have_content @my_provider_choice1.application_form.first_name
  end
end
