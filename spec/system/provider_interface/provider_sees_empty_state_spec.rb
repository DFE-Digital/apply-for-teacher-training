require 'rails_helper'

RSpec.feature 'See applications' do
  include CourseOptionHelpers
  include DfESignInHelpers

  scenario 'Provider user visits the Provider interface when there are no applications for their provider' do
    given_i_am_a_provider_user_authenticated_with_dfe_sign_in
    and_my_training_provider_exists
    and_another_organisation_has_applications

    when_i_have_been_assigned_to_my_training_provider
    and_i_sign_in_to_the_provider_interface

    then_i_should_see_no_applications
  end

  def given_i_am_a_provider_user_authenticated_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
    provider_signs_in_using_dfe_sign_in
  end

  def and_my_training_provider_exists
    create(:provider, code: 'ABC')
  end

  def and_another_organisation_has_applications
    other_course_option = course_option_for_provider_code(provider_code: 'ANOTHER_ORG')

    @other_provider_choice = create(:application_choice, :awaiting_provider_decision, status: 'awaiting_provider_decision', course_option: other_course_option)
  end

  def when_i_have_been_assigned_to_my_training_provider
    provider_user_exists_in_apply_database
  end

  def then_i_should_see_no_applications
    expect(page).to have_content 'You have not received any applications'
    expect(page).to have_no_css('.govuk-table')
  end
end
