require 'rails_helper'

RSpec.feature 'Candidate submits the application' do
  include CandidateHelper

  scenario 'One of the course options that the candidate picked is full' do
    given_the_candidate_completes_their_application
    and_one_of_the_course_options_is_now_full
    and_the_candidate_submits_their_application

    then_i_see_a_warning_that_the_course_is_now_full
    and_i_cannot_proceed
  end

  def given_the_candidate_completes_their_application
    candidate_completes_application_form
  end

  def and_one_of_the_course_options_is_now_full
    course_option = current_candidate.current_application.application_choices.first.course_option
    course_option.update!(vacancy_status: 'no_vacancies')
  end

  def and_the_candidate_submits_their_application
    candidate_submits_application
  end

  def then_i_see_a_warning_that_the_course_is_now_full
    expect(page).to have_content(/You cannot apply to.+because it has no vancancies/)
  end

  def and_i_cannot_proceed
    expect(page).not_to have_link('Continue')
  end
end
