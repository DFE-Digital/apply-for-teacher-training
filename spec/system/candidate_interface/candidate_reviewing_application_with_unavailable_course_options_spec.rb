require 'rails_helper'

RSpec.feature 'Candidate reviewing an application with unavailable course options' do
  include CandidateHelper

  scenario 'sees warning messages for unavailable course options' do
    given_i_am_signed_in
    and_i_chose_course_options_that_have_since_become_unavailable

    when_i_visit_the_review_application_page

    then_i_see_a_warning_for_the_course_that_is_not_running
    then_i_see_a_warning_for_the_course_with_no_vacancies
    then_i_see_a_warning_for_the_course_with_no_vacancies_at_my_chosen_site
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_chose_course_options_that_have_since_become_unavailable
    @option_where_course_not_running = create(
      :course_option,
      course: create(:course, exposed_in_find: false),
    )

    @option_where_course_has_no_vacancies = create(
      :course_option,
      :no_vacancies,
      course: create(:course, exposed_in_find: true),
    )
    create(:course_option, :no_vacancies, course: @option_where_course_has_no_vacancies.course)

    @option_where_no_vacancies_at_chosen_site = create(
      :course_option,
      :no_vacancies,
      course: create(:course, exposed_in_find: true),
    )
    create(:course_option, course: @option_where_no_vacancies_at_chosen_site.course)

    [
      @option_where_course_not_running,
      @option_where_course_has_no_vacancies,
      @option_where_no_vacancies_at_chosen_site,
    ].each do |option|
      create(
        :application_choice,
        application_form: @current_candidate.current_application,
        course_option: option,
      )
    end
  end

  def when_i_visit_the_review_application_page
    visit candidate_interface_application_form_path
    click_link 'Check your answers before submitting'
  end

  def then_i_see_a_warning_for_the_course_that_is_not_running
    warning_message = \
      "You cannot apply to '#{@option_where_course_not_running.course.name_and_code}' because it is not running"
    expect(page).to have_content warning_message
  end

  def then_i_see_a_warning_for_the_course_with_no_vacancies
    warning_message = \
      "You cannot apply to '#{@option_where_course_has_no_vacancies.course.name_and_code}' because it has no vacancies"
    expect(page).to have_content warning_message
  end

  def then_i_see_a_warning_for_the_course_with_no_vacancies_at_my_chosen_site
    warning_message = \
      "Your chosen site for '#{@option_where_no_vacancies_at_chosen_site.course.name_and_code}' has no vacancies."
    expect(page).to have_content warning_message
  end
end
