require 'rails_helper'

RSpec.describe 'Unavailable choices' do
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
    open_course = create(:course, :open, :with_course_options)
    hidden_course = create(:course, :open, :with_course_options, exposed_in_find: false)
    closed_course = create(:course, :open, :with_course_options, application_status: 'closed')

    # application_to_open_course
    create(:application_choice, course: open_course, status: 'awaiting_provider_decision')
    # application_to_closed_course
    create(:application_choice, course: closed_course, status: 'awaiting_provider_decision')
    # application_to_hidden_course
    create(:application_choice, course: hidden_course, status: 'awaiting_provider_decision')

    @application_with_no_vacancies = create(:application_choice, status: 'awaiting_provider_decision', course_option: create(:course_option, :open, vacancy_status: 'no_vacancies'))
    create(:application_choice, status: 'awaiting_provider_decision', course_option: create(:course_option, :open, site_still_valid: false))
  end

  def when_i_visit_the_performance_tab_in_support
    visit support_interface_candidates_path
    click_link_or_button 'Performance'
  end

  def and_i_click_on_unavailable_choices
    click_link_or_button 'Applications with unavailable choices'
  end

  def then_i_can_see_a_summary_of_unavailable_choices
    expect(page).to have_content('Applications with unavailable choices')
    expect(page).to have_content('Course closed by provider (1)')
    expect(page).to have_content('Course removed from Find (1)')
    expect(page).to have_content('Course has no vacancies (1)')
    expect(page).to have_content('Site no longer exists (1)')
  end

  def when_i_click_on_applications_with_no_vacancies
    click_link_or_button('Course has no vacancies')
  end

  def then_i_can_see_the_list_of_applications_without_vacancies
    expect(page).to have_content('Applications to courses that no longer have vacancies')
    expect(page).to have_content(@application_with_no_vacancies.application_form.full_name)
  end
end
