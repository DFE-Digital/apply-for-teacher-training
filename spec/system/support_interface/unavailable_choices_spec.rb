require 'rails_helper'

RSpec.feature 'Unavailable choices' do
  include DfESignInHelpers

  scenario 'View application choices for courses and sites that are no longer unavailable' do
    given_i_am_a_support_user
    and_there_are_candidates_and_application_forms_in_the_system

    when_i_visit_the_performance_tab_in_support
    and_i_click_on_unavailable_choices
    then_i_can_see_a_summary_of_unavailable_choices

    when_i_click_on_applications_with_no_vacancies
    then_i_can_see_the_list_of_applications_without_vacancies
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_are_candidates_and_application_forms_in_the_system
    application_to_open_course = create(:application_choice, status: 'awaiting_provider_decision')
    application_to_open_course.course.update! open_on_apply: true
    application_to_closed_course = create(:application_choice, status: 'awaiting_provider_decision')
    application_to_closed_course.course.update! open_on_apply: false
    application_to_hidden_course = create(:application_choice, status: 'awaiting_provider_decision')
    application_to_hidden_course.course.update! open_on_apply: true, exposed_in_find: false
    @application_with_no_vacancies = create(:application_choice, status: 'awaiting_provider_decision', course_option: create(:course_option, vacancy_status: 'no_vacancies'))
    create(:application_choice, status: 'awaiting_provider_decision', course_option: create(:course_option, site_still_valid: false))
  end

  def when_i_visit_the_performance_tab_in_support
    visit support_interface_candidates_path
    click_on 'Performance'
  end

  def and_i_click_on_unavailable_choices
    click_on 'Applications with unavailable choices'
  end

  def then_i_can_see_a_summary_of_unavailable_choices
    expect(page).to have_content(
      'Applications to courses that are no longer available on Apply (3)',
    )
    expect(page).to have_content(
      'Applications to courses that have been removed from Find, but were open on Apply (1)',
    )
    expect(page).to have_content(
      'Applications to courses that no longer have vacancies (1)',
    )
    expect(page).to have_content(
      'Applications to sites that no longer exist (1)',
    )
  end

  def when_i_click_on_applications_with_no_vacancies
    click_on('Applications to courses that no longer have vacancies')
  end

  def then_i_can_see_the_list_of_applications_without_vacancies
    expect(page).to have_content('Applications to courses that no longer have vacancies')
    expect(page).to have_content(@application_with_no_vacancies.application_form.full_name)
  end
end
