require 'rails_helper'

RSpec.feature 'Candidate submits the application with a course that is not available and full' do
  include CandidateHelper

  it 'Candidate with a completed application form' do
    given_i_complete_my_application
    and_the_selected_course_is_not_yet_open
    and_my_second_choice_is_full
    and_i_submit_my_application

    then_i_see_a_message_that_i_cannot_submit_my_application
  end

  def given_i_complete_my_application
    candidate_completes_application_form
  end

  def and_the_selected_course_is_not_yet_open
    @course = current_candidate.current_application.application_choices.first.course
    @course.update!(applications_open_from: 1.day.from_now)
  end

  def and_my_second_choice_is_full
    @second_course = create(:course)
    course_option = create(:course_option, vacancy_status: 'no_vacancies', course: @second_course)
    create(:application_choice, application_form: current_candidate.current_application, course_option: course_option)
  end

  def and_i_submit_my_application
    click_link 'Check and submit your application'
  end

  def then_i_see_a_message_that_i_cannot_submit_my_application
    expect(page).to have_text 'You cannot submit this application as:'
    expect(page).to have_text "#{@course.name_and_code} will not open for applications until #{@course.applications_open_from.to_fs(:govuk_date)}"
    expect(page).to have_text "#{@second_course.name_and_code} has no vacancies"
  end
end
