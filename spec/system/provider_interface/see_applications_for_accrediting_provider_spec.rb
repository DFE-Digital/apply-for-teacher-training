require 'rails_helper'

RSpec.feature 'See applications for accredited provider' do
  include CourseOptionHelpers
  include DfESignInHelpers

  scenario 'Provider visits application page' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_for_my_provider
    and_my_organisation_has_accredited_courses_with_applications
    and_i_sign_in_to_the_provider_interface

    and_i_visit_the_provider_page
    then_i_should_see_the_applications_from_my_organisation
    but_not_the_applications_from_other_providers
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_am_permitted_to_see_applications_for_my_provider
    @provider_user = provider_user_exists_in_apply_database
  end

  def and_my_organisation_has_accredited_courses_with_applications
    current_provider = @provider_user.providers.first
    other_provider = create(:provider, code: 'ANOTHER_ORG')
    course_option = course_option_for_provider(provider: current_provider)
    accredited_course_option_where_current_provider_is_accredited = course_option_for_accredited_provider(provider: other_provider, accredited_provider: current_provider)
    accredited_course_option_where_current_provider_is_main_provider = course_option_for_accredited_provider(provider: current_provider, accredited_provider: other_provider)

    other_course_option = course_option_for_provider(provider: other_provider)

    create(:application_choice, status: 'awaiting_provider_decision', course_option:, application_form: create(:application_form, first_name: 'Jim', last_name: 'Jones'))
    create(:application_choice, status: 'awaiting_provider_decision', course_option: accredited_course_option_where_current_provider_is_accredited, application_form: create(:application_form, first_name: 'Clancy'))
    create(:application_choice, status: 'awaiting_provider_decision', course_option: accredited_course_option_where_current_provider_is_main_provider, application_form: create(:application_form, first_name: 'Harry'))
    create(:application_choice, status: 'awaiting_provider_decision', course_option: other_course_option, application_form: create(:application_form, first_name: 'Bert'))
  end

  def and_i_visit_the_provider_page
    visit provider_interface_path
  end

  def then_i_should_see_the_applications_from_my_organisation
    expect(page).to have_link 'Jim'
    expect(page).to have_link 'Clancy'
    expect(page).to have_link 'Harry'
  end

  def but_not_the_applications_from_other_providers
    expect(page).not_to have_link 'Bert'
  end
end
