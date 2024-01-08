require 'rails_helper'

RSpec.describe 'Candidate providing feedback on Find' do
  include CandidateHelper

  scenario 'Candidate arrives from Find and provides feedback' do
    given_i_arrive_from_the_course_show_page

    when_i_complete_and_submit_the_feedback_form_with_an_invalid_email_address
    then_i_am_asked_to_provide_a_valid_email_address

    when_i_provide_a_valid_email_address
    then_i_am_thanked_for_my_feedback
    and_my_feedback_on_the_course_page_has_been_persisted

    given_i_arrive_from_the_results_page

    when_i_complete_and_submit_the_feedback_form
    then_i_am_thanked_for_my_feedback
    and_my_feedback_on_the_results_page_has_been_persisted

    given_i_arrive_without_query_string_params
    and_i_submit_my_email_and_feedback
    then_i_am_told_i_need_path_and_controller_params_to_give_feedback

    given_i_arrive_from_the_course_show_page
    and_i_fill_in_the_hidden_field_designed_to_catch_bots
    then_i_am_thanked_for_my_feedback
  end

  def given_i_arrive_from_the_course_show_page
    visit candidate_interface_find_feedback_path(find_controller: 'courses', path: '/course/T92/X130')
  end

  def when_i_complete_and_submit_the_feedback_form_with_an_invalid_email_address
    fill_in t('find_feedback.feedback.label.course'), with: 'Make it better.'
    fill_in 'Email address (optional)', with: 'email'

    click_link_or_button 'Submit feedback'
  end

  def then_i_am_asked_to_provide_a_valid_email_address
    expect_validation_error 'Enter an email address in the correct format, like name@example.com'
  end

  def when_i_provide_a_valid_email_address
    fill_in 'Email address (optional)', with: 'email@gmail.com'
    click_link_or_button 'Submit feedback'
  end

  def then_i_am_thanked_for_my_feedback
    expect(page).to have_content 'Thank you for your feedback'
  end

  def and_my_feedback_on_the_course_page_has_been_persisted
    feedback = FindFeedback.last

    expect(FindFeedback.count).to eq 1
    expect(feedback.find_controller).to eq 'courses'
    expect(feedback.path).to eq '/course/T92/X130'
    expect(feedback.feedback).to eq 'Make it better.'
  end

  def given_i_arrive_from_the_results_page
    visit candidate_interface_find_feedback_path(find_controller: 'results', path: 'results?l=2&subjects%5B%5D=31')
  end

  def when_i_complete_and_submit_the_feedback_form
    fill_in t('find_feedback.feedback.label.results'), with: 'The pagination numbers are off.'
    fill_in 'Email address (optional)', with: 'email@gmail.com'

    click_link_or_button 'Submit feedback'
  end

  def and_my_feedback_on_the_results_page_has_been_persisted
    feedback = FindFeedback.last

    expect(FindFeedback.count).to eq 2
    expect(feedback.find_controller).to eq 'results'
    expect(feedback.path).to eq 'results?l=2&subjects%5B%5D=31'
    expect(feedback.feedback).to eq 'The pagination numbers are off.'
  end

  def given_i_arrive_without_query_string_params
    visit candidate_interface_find_feedback_path
  end

  def and_i_submit_my_email_and_feedback
    fill_in t('find_feedback.feedback.label.unknown'), with: 'The pagination numbers are off.'
    fill_in 'Email address (optional)', with: 'email@gmail.com'

    click_link_or_button 'Submit feedback'
  end

  def then_i_am_told_i_need_path_and_controller_params_to_give_feedback
    expect(page).to have_content 'Path cannot be blank'
    expect(page).to have_content 'Find controller cannot be blank'
  end

  def and_i_fill_in_the_hidden_field_designed_to_catch_bots
    fill_in 'Do not fill in. To catch bots', with: 'bleep bloop'
    click_link_or_button 'Submit feedback'
  end
end
