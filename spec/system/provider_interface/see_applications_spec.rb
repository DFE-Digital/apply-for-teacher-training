require 'rails_helper'

RSpec.feature 'See applications' do
  include CourseOptionHelpers
  include DfeSignInHelpers

  scenario 'Provider visits application page' do
    given_i_am_a_provider_user_authenticated_with_dfe_sign_in
    and_my_organisation_has_applications
    and_i_visit_the_provider_page
    then_i_should_see_the_applications_from_my_organisation
    but_not_the_applications_from_other_providers

    when_i_click_on_an_application
    then_i_should_be_on_the_application_view_page
  end

  def given_i_am_a_provider_user_authenticated_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
    provider_signs_in_using_dfe_sign_in
  end

  def and_my_organisation_has_applications
    course_option = course_option_for_provider_code(provider_code: 'ABC')
    other_course_option = course_option_for_provider_code(provider_code: 'ANOTHER_ORG')

    create(:application_choice, status: 'awaiting_provider_decision', course_option: course_option, application_form: create(:application_form, first_name: 'Alice', last_name: 'Wunder'))
    create(:application_choice, status: 'awaiting_provider_decision', course_option: course_option, application_form: create(:application_form, first_name: 'Bob'))
    create(:application_choice, status: 'awaiting_provider_decision', course_option: other_course_option, application_form: create(:application_form, first_name: 'Charlie'))
  end

  def and_i_visit_the_provider_page
    visit provider_interface_path
  end

  def then_i_should_see_the_applications_from_my_organisation
    expect(page).to have_content 'Alice'
    expect(page).to have_content 'Bob'
  end

  def but_not_the_applications_from_other_providers
    expect(page).not_to have_content 'Charlie'
  end

  def when_i_click_on_an_application
    click_on 'Alice'
  end

  def then_i_should_be_on_the_application_view_page
    expect(page).to have_content 'Application for'
    expect(page).to have_content 'Alice Wunder'
  end
end
