require 'rails_helper'

RSpec.feature 'See applications' do
  include CourseOptionHelpers

  scenario 'Provider visits application page' do
    given_i_am_a_provider_user
    and_my_organisation_has_accredited_courses_with_applications
    and_i_visit_the_provider_page
    then_i_should_see_the_applications_from_my_organisation
    but_not_the_applications_from_other_providers
  end

  def given_i_am_a_provider_user
    # This is stubbed out for now in the controller.
  end

  def and_my_organisation_has_accredited_courses_with_applications
    current_provider = create(:provider, code: 'ABC')
    other_provier = create(:provider, code: 'ANOTHER_ORG')
    course_option = course_option_for_provider(provider: current_provider)
    accredited_course_option_where_current_provider_is_accrediting = course_option_for_accrediting_provider(provider: other_provier, accrediting_provider: current_provider)
    accredited_course_option_where_current_provider_is_main_provider = course_option_for_accrediting_provider(provider: current_provider, accrediting_provider: other_provier)


    other_course_option = course_option_for_provider(provider: other_provier)

    create(:application_choice, status: 'awaiting_provider_decision', course_option: course_option, application_form: create(:application_form, first_name: 'Jim', last_name: 'Jones'))
    create(:application_choice, status: 'awaiting_provider_decision', course_option: accredited_course_option_where_current_provider_is_accrediting, application_form: create(:application_form, first_name: 'Clancy'))
    create(:application_choice, status: 'awaiting_provider_decision', course_option: accredited_course_option_where_current_provider_is_main_provider, application_form: create(:application_form, first_name: 'Harry'))
    create(:application_choice, status: 'awaiting_provider_decision', course_option: other_course_option, application_form: create(:application_form, first_name: 'Bert'))
  end

  def and_i_visit_the_provider_page
    visit provider_interface_path
  end

  def then_i_should_see_the_applications_from_my_organisation
    expect(page).to have_content 'Jim'
    expect(page).to have_content 'Clancy'
    expect(page).to have_content 'Harry'
  end

  def but_not_the_applications_from_other_providers
    expect(page).not_to have_content 'Bert'
  end
end
