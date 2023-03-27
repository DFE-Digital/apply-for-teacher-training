require 'rails_helper'

RSpec.feature 'Entering "Personal statement"' do
  include CandidateHelper

  before do
    TestSuiteTimeMachine.travel_permanently_to(ApplicationForm::SINGLE_PERSONAL_STATEMENT_FROM + 1.day)
  end

  scenario 'Candidate submits personal statement' do
    given_the_feature_flag_is_active
    given_i_am_signed_in
    and_i_visit_the_site

    when_i_click_on_personal_statement
    and_i_submit_the_form
    then_i_should_return_to_the_application

    when_i_click_on_personal_statement
    and_i_fill_in_more_than_1000_words
    and_i_submit_the_form
    then_i_should_see_a_validation_error
    and_a_validation_error_is_logged_for_becoming_a_teacher

    when_i_fill_in_an_answer
    and_i_submit_the_form
    then_i_can_check_my_answers

    when_i_click_to_change_my_answer
    and_i_fill_in_a_different_answer
    and_i_submit_the_form
    then_i_can_check_my_revised_answers

    when_i_mark_the_section_as_completed
    and_i_submit_the_form
    then_i_should_see_the_form
    and_that_the_section_is_completed

    when_i_click_on_personal_statement
    then_i_can_check_my_revised_answers
  end

  def given_the_feature_flag_is_active
    FeatureFlag.activate(:one_personal_statement)
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_personal_statement
    click_link 'Your personal statement'
  end

  def then_i_should_see_a_validation_error
    expect(page).to have_content 'Your answer must be 1000 words or less'
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

  def and_i_fill_in_more_than_1000_words
    fill_in 'Your personal statement', with: ('test ' * 1_001)
  end

  def when_i_fill_in_an_answer
    fill_in 'Your personal statement', with: 'Hello world'
  end

  def then_i_can_check_my_answers
    expect(page).to have_content 'Personal statement'
    expect(page).to have_content 'Hello world'
  end

  def and_i_submit_the_form
    click_button t('continue')
  end

  def when_i_click_to_change_my_answer
    click_change_link('personal statement')
  end

  def and_i_fill_in_a_different_answer
    fill_in 'Your personal statement', with: 'Hello world again'
  end

  def then_i_can_check_my_revised_answers
    expect(page).to have_content 'Personal statement'
    expect(page).to have_content 'Hello world again'
  end

  def when_i_mark_the_section_as_completed
    choose t('application_form.completed_radio')
  end

  def then_i_should_see_the_form
    expect(page).to have_content('Your personal statement')
  end

  def and_that_the_section_is_completed
    expect(page).to have_css('#your-personal-statement-badge-id', text: 'Completed')
  end

  def then_i_should_return_to_the_application
    expect(page).to have_content('Your application')
  end
end
