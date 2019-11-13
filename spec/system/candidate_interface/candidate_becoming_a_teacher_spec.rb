require 'rails_helper'

RSpec.feature 'Entering "Why do you want to be a teacher?"' do
  include CandidateHelper

  scenario 'Candidate submits why they want to be a teacher' do
    given_i_am_signed_in
    and_i_visit_the_site

    when_i_click_on_becoming_a_teacher
    and_i_submit_the_form
    then_i_should_see_validation_errors

    when_i_fill_in_an_answer
    and_i_submit_the_form
    then_i_can_check_my_answers

    when_i_click_to_change_my_answer
    and_i_fill_in_a_different_answer
    and_i_submit_the_form
    then_i_can_check_my_revised_answers

    when_i_submit_my_details
    then_i_should_see_the_form
    and_that_the_section_is_completed

    when_i_click_on_becoming_a_teacher
    then_i_can_check_my_revised_answers
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_becoming_a_teacher
    click_link t('page_titles.becoming_a_teacher')
  end

  def then_i_should_see_validation_errors
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/becoming_a_teacher_form.attributes.becoming_a_teacher.blank')
  end

  def and_i_fill_in_some_details_but_omit_some_required_details
    scope = 'application_form.personal_statement'
    fill_in t('becoming_a_teacher.label', scope: scope), with: 'Hello world'
  end

  def when_i_fill_in_an_answer
    scope = 'application_form.personal_statement'
    fill_in t('becoming_a_teacher.label', scope: scope), with: 'Hello world'
  end

  def then_i_can_check_my_answers
    expect(page).to have_content 'Why do you want to be a teacher?'
    expect(page).to have_content 'Hello world'
  end

  def and_i_submit_the_form
    click_button t('application_form.personal_statement.becoming_a_teacher.complete_form_button')
  end

  def when_i_click_to_change_my_answer
    first('.govuk-summary-list__actions').click_link 'Change'
  end

  def and_i_fill_in_a_different_answer
    scope = 'application_form.personal_statement'
    fill_in t('becoming_a_teacher.label', scope: scope), with: 'Hello world again'
  end

  def then_i_can_check_my_revised_answers
    expect(page).to have_content 'Tell us why you want to be a teacher'
    expect(page).to have_content 'Hello world again'
  end

  def when_i_submit_my_details
    click_link 'Continue'
  end

  def then_i_should_see_the_form
    expect(page).to have_content(t('page_titles.becoming_a_teacher'))
  end

  def and_that_the_section_is_completed
    expect(page).to have_css('#becoming-a-teacher-completed', text: 'Completed')
  end
end
