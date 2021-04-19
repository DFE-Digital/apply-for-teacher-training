require 'rails_helper'

RSpec.feature 'Candidate submits the application with full course study mode' do
  include CandidateHelper

  scenario 'The location that the candidate picked has no full time vacancies but does have part time vacancies' do
    given_i_complete_my_application
    and_the_selected_full_time_course_option_is_now_full
    and_the_selected_course_is_available_part_time_at_the_same_location
    and_i_submit_my_application

    then_i_see_a_warning_that_there_are_no_full_time_vacancies
    and_i_cannot_proceed
  end

  def given_i_complete_my_application
    candidate_completes_application_form
  end

  def and_the_selected_full_time_course_option_is_now_full
    course_option = current_candidate.current_application.application_choices.first.course_option
    course_option.update!(vacancy_status: 'no_vacancies')
  end

  def and_the_selected_course_is_available_part_time_at_the_same_location
    selected_course_option = current_candidate.current_application.application_choices.first
    create(
      :course_option,
      site: selected_course_option.site,
      course: selected_course_option.course,
      study_mode: 'part_time',
    )
  end

  def and_i_submit_my_application
    click_link 'Check and submit your application'
  end

  def then_i_see_a_warning_that_there_are_no_full_time_vacancies
    expect(page).to have_content("Your chosen location for ‘#{current_candidate.current_application.application_choices.first.course.provider_and_name_code}’ has no full time vacancies")
  end

  def and_i_cannot_proceed
    click_link t('continue')
    expect(page).to have_content('There is a problem')
    expect(page).to have_content("Your chosen location for ‘#{current_candidate.current_application.application_choices.first.course.provider_and_name_code}’ has no full time vacancies")
  end
end
