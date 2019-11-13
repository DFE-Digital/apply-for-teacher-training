require 'rails_helper'

RSpec.feature 'Entering subject knowledge' do
  include CandidateHelper

  scenario 'Candidate submits their subject knowledge' do
    given_i_am_signed_in
    and_i_visit_the_site

    when_i_click_on_subject_knowledge
    and_i_submit_the_form
    then_i_should_see_validation_errors

    when_i_fill_in_an_answer
    and_i_submit_the_form
    then_i_can_check_my_answers

    when_i_click_to_change_my_answer
    and_i_fill_in_a_different_answer
    and_i_submit_the_form
    then_i_can_check_my_revised_answers

    when_i_submit_my_subject_knowledge
    then_i_should_see_the_form
    and_that_the_section_is_completed

    when_i_click_on_subject_knowledge
    then_i_can_check_my_revised_answers
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_subject_knowledge
    click_link t('page_titles.subject_knowledge')
  end

  def and_i_submit_the_form
    click_button t('application_form.personal_statement.subject_knowledge.complete_form_button')
  end

  def when_i_click_to_change_my_answer
    first('.govuk-summary-list__actions').click_link 'Change'
  end

  def when_i_fill_in_an_answer
    scope = 'application_form.personal_statement'
    fill_in t('subject_knowledge.label', scope: scope), with: 'Hello world'
  end

  def then_i_can_check_my_answers
    expect(page).to have_content 'Your knowledge about the subject you want to teach'
    expect(page).to have_content 'Hello world'
  end

  def then_i_should_see_validation_errors
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/subject_knowledge_form.attributes.subject_knowledge.blank')
  end

  def and_i_fill_in_a_different_answer
    scope = 'application_form.personal_statement'
    fill_in t('subject_knowledge.label', scope: scope), with: 'Hello world again'
  end

  def then_i_can_check_my_revised_answers
    expect(page).to have_content 'Your knowledge about the subject you want to teach'
    expect(page).to have_content 'Hello world again'
  end

  def when_i_submit_my_subject_knowledge
    click_link 'Continue'
  end

  def then_i_should_see_the_form
    expect(page).to have_content(t('page_titles.subject_knowledge'))
  end

  def and_that_the_section_is_completed
    expect(page).to have_css('#subject-knowledge-completed', text: 'Completed')
  end
end
