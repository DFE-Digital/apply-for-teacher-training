require 'rails_helper'

RSpec.describe 'Candidate tries to submit an application choice when the course is unavailable' do
  include CandidateHelper
  before do
    given_i_am_signed_in_with_one_login
    and_i_have_one_application_in_draft
  end

  scenario 'Course becomes closed' do
    and_my_course_choice_becomes_closed
    when_i_visit_my_applications
    and_i_click_to_view_my_application
    then_i_see_that_the_course_is_closed
    when_i_visit_the_review_page_directly
    then_i_see_the_course_closed_error_message
    and_i_do_not_see_notice_to_delete_draft
    when_i_click_to_remove_the_application
    and_i_confirm_to_remove_the_application
    then_my_application_choice_is_removed
  end

  scenario 'Course becomes full' do
    and_my_course_choice_becomes_full
    when_i_visit_my_applications
    and_i_click_to_view_my_application
    then_i_see_that_the_course_is_unavailable
    when_i_visit_the_review_page_directly
    then_i_see_the_course_unavailable_error_message
    and_i_do_not_see_notice_to_delete_draft
    when_i_click_to_remove_the_application
    and_i_confirm_to_remove_the_application
    then_my_application_choice_is_removed
  end

  scenario 'Invalid course location' do
    and_my_course_location_is_not_valid_anymore
    when_i_visit_my_applications
    and_i_click_to_view_my_application
    then_i_see_the_course_unavailable_error_message
    and_i_do_not_see_notice_to_delete_draft
    when_i_click_to_remove_the_application
    and_i_confirm_to_remove_the_application
    then_my_application_choice_is_removed
  end

  scenario 'Course not exposed in find' do
    and_my_course_choice_is_not_exposed_in_find_anymore
    when_i_continue_my_draft_application
    then_i_see_the_course_unavailable_error_message
    and_i_do_not_see_notice_to_delete_draft
    when_i_click_to_remove_the_application
    and_i_confirm_to_remove_the_application
    then_my_application_choice_is_removed
  end

  def and_my_course_choice_becomes_closed
    @application_choice.current_course.update(application_status: 'closed')
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

  def and_i_do_not_see_notice_to_delete_draft
    expect(page).to have_no_content('Delete draft application')
  end

  def then_i_see_the_course_closed_error_message
    within('.govuk-warning-text') do
      expect(page).to have_content('You cannot submit this application because the course has closed.')
    end
  end

  def then_i_see_the_course_unavailable_error_message
    within('.govuk-warning-text') do
      expect(page).to have_content('You cannot submit this application because the course is no longer available.')
    end
  end

  def then_i_not_see_the_continue_application_link
    expect(page).to have_no_content('Continue application')
  end

  def when_i_visit_the_review_page_directly
    visit candidate_interface_course_choices_course_review_path(@application_choice.id)
  end

  def when_i_click_to_remove_the_application
    click_link_or_button 'Remove this application'
  end

  def and_i_confirm_to_remove_the_application
    click_link_or_button 'Yes I’m sure - delete this application'
  end

  def then_my_application_choice_is_removed
    expect(@application_form.reload.application_choices.count).to be_zero
  end

  def then_i_see_that_the_course_is_closed
    expect(page).to have_content('You cannot submit this application because the course has closed.')
    expect(page).to have_content('Remove this application and search for other courses.')
  end
end
