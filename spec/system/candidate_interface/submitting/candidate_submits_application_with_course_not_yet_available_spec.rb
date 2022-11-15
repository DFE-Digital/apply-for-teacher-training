
require 'rails_helper'

RSpec.feature 'Candidate submits the application with full course study mode' do
  include CandidateHelper

  it 'The location that the candidate picked has no full time vacancies but does have part time vacancies' do
    given_i_complete_my_application
    and_the_selected_course_is_not_yet_open
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

  def and_i_submit_my_application
    click_link 'Check and submit your application'
  end

  def then_i_see_a_message_that_i_cannot_submit_my_application
    expect(page).to have_text 'You cannot submit this application because:'
    expect(page).to have_text "you can only apply for #{@course.name_and_code} from #{@course.applications_open_from.to_fs(:govuk_date)}"
  end
end
