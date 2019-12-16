require 'rails_helper'

RSpec.feature 'Entering interview preferences' do
  include CandidateHelper

  scenario 'Candidate submits their interview preferences' do
    given_i_am_signed_in
    and_i_visit_the_site

    when_i_click_on_interview_preferences
    and_i_submit_the_form
    then_i_should_see_validation_errors

    when_i_choose_yes_and_enter_my_preferences
    and_i_submit_the_form
    then_i_can_check_my_answers

    when_i_click_to_change_my_answer
    and_i_choose_no
    and_i_submit_the_form
    then_i_can_check_my_revised_answers

    when_i_submit_my_interview_preferences
    then_i_should_see_the_form
    and_that_the_section_is_completed

    when_i_click_on_interview_preferences
    then_i_can_check_my_revised_answers
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_interview_preferences
    click_link t('page_titles.interview_preferences')
  end

  def and_i_submit_the_form
    click_button t('application_form.personal_statement.interview_preferences.complete_form_button')
  end

  def when_i_click_to_change_my_answer
    first('.govuk-summary-list__actions').click_link 'Change'
  end

  def when_i_choose_yes_and_enter_my_preferences
    scope = 'application_form.personal_statement'

    choose 'Yes'
    fill_in t('interview_preferences.yes_label', scope: scope), with: 'Hello world'
  end

  def then_i_can_check_my_answers
    expect(page).to have_content t('page_titles.interview_preferences')
    expect(page).to have_content 'Hello world'
  end

  def then_i_should_see_validation_errors
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/interview_preferences_form.attributes.any_preferences.blank')
  end

  def and_i_choose_no
    choose 'No'
  end

  def then_i_can_check_my_revised_answers
    expect(page).to have_content t('page_titles.interview_preferences')
    expect(page).to have_content t('application_form.personal_statement.interview_preferences.no_value')
  end

  def when_i_submit_my_interview_preferences
    click_link 'Continue'
  end

  def then_i_should_see_the_form
    expect(page).to have_content(t('page_titles.interview_preferences'))
  end

  def and_that_the_section_is_completed
    expect(page).to have_css('#interview-preferences-badge-id', text: 'Completed')
  end
end
