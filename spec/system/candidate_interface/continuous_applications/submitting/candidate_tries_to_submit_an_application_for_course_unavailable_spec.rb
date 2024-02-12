require 'rails_helper'

RSpec.feature 'Candidate tries to submit an application choice which the course is unavailable' do
  include SignInHelper
  include CandidateSubmissionHelper
  before do
    given_i_am_signed_in
    and_i_have_one_application_in_draft
  end

  after do
    when_i_click_to_remove_the_application
    and_i_confirm_to_remove_the_application
    then_my_application_choice_should_be_removed
  end

  scenario 'Course becomes full' do
    and_my_course_choice_becomes_full
    when_i_visit_my_applications
    then_i_should_see_that_the_course_is_full
    when_i_visit_the_review_page_directly
    then_i_should_see_the_course_unavailable_error_message
  end

  scenario 'Invalid course location' do
    and_my_course_location_is_not_valid_anymore
    when_i_visit_my_applications
    then_i_should_not_see_the_continue_application_link
    when_i_visit_the_review_page_directly
    then_i_should_see_the_course_unavailable_error_message
  end

  scenario 'Course not exposed in find' do
    and_my_course_choice_is_not_exposed_in_find_anymore
    when_i_continue_my_draft_application
    then_i_should_see_the_course_unavailable_error_message
  end

  def and_my_course_choice_becomes_full
    @application_choice.current_course.course_options.update_all(vacancy_status: 'no_vacancies')
  end

  def and_my_course_location_is_not_valid_anymore
    @application_choice.current_course.course_options.update_all(site_still_valid: false)
  end

  def and_my_course_choice_is_not_exposed_in_find_anymore
    @application_choice.current_course.update(exposed_in_find: false)
  end

  def then_i_should_see_the_course_unavailable_error_message
    expect(page).to have_content('You cannot submit this application as the course is no longer available.')
  end

  def then_i_should_not_see_the_continue_application_link
    expect(page).to have_no_content('Continue application')
  end

  def when_i_visit_the_review_page_directly
    visit candidate_interface_continuous_applications_course_review_path(@application_choice.id)
  end

  def when_i_click_to_remove_the_application
    click_link_or_button 'Remove this application'
  end

  def and_i_confirm_to_remove_the_application
    click_link_or_button 'Yes I’m sure - delete this application'
  end

  def then_my_application_choice_should_be_removed
    expect(@application_form.reload.application_choices.count).to be_zero
  end
end
