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

    then_i_cannot_submit_the_application
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_chose_course_options_that_have_since_become_unavailable
    @option_where_course_not_running = create(
      :course_option,
      course: create(:course, :open_on_apply, exposed_in_find: false),
    )

    @option_where_course_has_no_vacancies = create(
      :course_option,
      :no_vacancies,
      course: create(:course, :open_on_apply),
    )
    create(:course_option, :no_vacancies, course: @option_where_course_has_no_vacancies.course)

    @option_where_no_vacancies_at_chosen_site = create(
      :course_option,
      :no_vacancies,
      course: create(:course, :open_on_apply),
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
    click_link 'Check and submit your application'
  end

  def then_i_see_a_warning_for_the_course_that_is_not_running
    expect(page).to have_content 'You cannot apply to this course as it is not running'
  end

  def then_i_see_a_warning_for_the_course_with_no_vacancies
    expect(page).to have_content 'You cannot apply to this course as there are no places left on it'
  end

  def then_i_see_a_warning_for_the_course_with_no_vacancies_at_my_chosen_site
    expect(page).to have_content 'You cannot apply to this course as the chosen location is full'
  end

  def then_i_cannot_submit_the_application
    expect(page).to have_content 'You cannot submit this application as:'
    expect(page).to have_content "#{@option_where_course_has_no_vacancies.course.name_and_code} has no vacancies"
    expect(page).to have_content "#{@option_where_no_vacancies_at_chosen_site.course.name_and_code} has no vacancies"
  end

private

  def course_not_running_message
    "You cannot apply to ‘#{@option_where_course_not_running.course.provider_and_name_code}’ because it is not running"
  end

  def course_has_no_vacancies_message
    "You cannot apply to ‘#{@option_where_course_has_no_vacancies.course.provider_and_name_code}’ because it has no vacancies"
  end

  def chosen_site_has_no_vacancies_message
    "Your chosen location for ‘#{@option_where_no_vacancies_at_chosen_site.course.provider_and_name_code}’ has no vacancies"
  end

  def course_closed_on_apply_message
    "‘#{@option_where_course_not_running.course.name_and_code}’ at #{@option_where_course_not_running.course.provider.name} is not available on Apply for teacher training anymore"
  end
end
