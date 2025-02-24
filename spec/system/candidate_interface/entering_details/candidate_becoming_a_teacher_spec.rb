require 'rails_helper'

RSpec.describe 'Entering "Why do you want to be a teacher?"' do
  include CandidateHelper

  scenario 'Candidate submits why they want to be a teacher' do
    given_i_am_signed_in_with_one_login
    and_i_visit_the_site

    when_i_click_on_becoming_a_teacher
    and_i_fill_in_an_answer
    and_i_submit_the_form
    then_i_can_check_my_answers

    when_i_click_to_change_my_answer
    and_i_fill_in_a_different_answer
    and_i_submit_the_form
    then_i_can_check_my_revised_answers

    when_i_mark_the_section_as_completed
    and_i_submit_the_form
    then_i_see_the_form
    and_that_the_section_is_completed

    when_i_click_on_becoming_a_teacher
    then_i_can_check_my_revised_answers
  end

  def and_i_visit_the_site
    visit candidate_interface_details_path
  end

  def when_i_click_on_becoming_a_teacher
    click_link_or_button 'Your personal statement'
  end

  def and_a_validation_error_is_logged_for_becoming_a_teacher
    validation_error = ValidationError.last
    expect(validation_error).to be_present
    expect(validation_error.details).to have_key('becoming_a_teacher')
    expect(validation_error.user).to eq(current_candidate)
    expect(validation_error.request_path).to eq(candidate_interface_new_becoming_a_teacher_path)
    expect(validation_error.service).to eq('apply')
  end

  def and_i_fill_in_some_details_but_omit_some_required_details
    fill_in 'Your personal statement', with: 'Hello world'
  end

  def and_i_fill_in_an_answer
    fill_in 'Your personal statement', with: 'Hello world'
  end

  def then_i_can_check_my_answers
    expect(page).to have_content 'Check your personal statement'
    expect(page).to have_content 'Hello world'
  end

  def and_i_submit_the_form
    click_link_or_button t('continue')
  end

  def then_i_should_return_to_the_application
    expect(page).to have_content('Your application')
  end

  def when_i_click_to_change_my_answer
    click_link_or_button('Edit your personal statement')
  end

  def and_i_fill_in_a_different_answer
    fill_in 'Your personal statement', with: 'Hello world again'
  end

  def then_i_can_check_my_revised_answers
    expect(page).to have_content 'Check your personal statement'
    expect(page).to have_content 'Hello world again'
  end

  def when_i_mark_the_section_as_completed
    choose t('application_form.completed_radio')
  end

  def then_i_see_the_form
    expect(page).to have_content(t('page_titles.personal_statement'))
  end

  def and_that_the_section_is_completed
    expect(page).to have_css('#your-personal-statement-badge-id', text: 'Completed')
  end
end
