require 'rails_helper'

RSpec.feature 'Selecting a course' do
  include CandidateHelper

  scenario 'Candidate does not know what course to apply for' do
    given_i_am_signed_in

    when_i_visit_the_site
    and_i_click_on_course_choices
    and_i_click_on_add_course
    and_i_choose_that_i_do_not_know_where_i_want_to_apply
    then_i_should_be_on_the_find_a_course_page

    when_i_click_start_now
    then_i_am_sent_to_find
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def when_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def and_i_click_on_course_choices
    click_link 'Course choices'
  end

  def and_i_click_on_add_course
    click_link 'Continue'
  end

  def and_i_choose_that_i_do_not_know_where_i_want_to_apply
    choose 'No, I need to find a course'
    click_button 'Continue'
  end

  def then_i_should_be_on_the_find_a_course_page
    expect(page).to have_current_path(candidate_interface_go_to_find_path)
  end

  def when_i_click_start_now
    click_link 'Start now'
  end

  def then_i_am_sent_to_find
    expect(page.current_url).to include('https://www.find-postgraduate-teacher-training.service.gov.uk')
  end
end
