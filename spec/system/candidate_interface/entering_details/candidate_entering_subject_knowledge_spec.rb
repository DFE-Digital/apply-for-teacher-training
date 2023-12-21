require 'rails_helper'

RSpec.feature 'Entering subject knowledge', :continuous_applications do
  include CandidateHelper

  it 'Candidate submits their subject knowledge', skip: 'Revisit non continuous applications' do
    given_courses_exist

    given_i_am_signed_in
    and_i_visit_the_site

    when_i_click_on_subject_knowledge
    and_i_submit_the_form
    then_i_should_return_to_the_application

    when_i_click_on_subject_knowledge
    and_i_fill_in_an_answer
    and_i_submit_the_form
    then_i_can_check_my_answers

    when_i_click_to_change_my_answer
    and_i_fill_in_a_different_answer
    and_i_submit_the_form
    then_i_can_check_my_revised_answers

    when_i_click_on_continue
    then_i_see_a_section_complete_error

    when_i_mark_the_section_as_completed
    and_i_submit_my_subject_knowledge
    then_i_should_see_the_form
    and_that_the_section_is_completed

    when_i_click_on_subject_knowledge
    then_i_can_check_my_revised_answers
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_visit_the_site
    visit candidate_interface_continuous_applications_details_path
  end

  def when_i_click_on_subject_knowledge
    click_link t('page_titles.subject_knowledge')
  end

  def and_i_submit_the_form
    click_button t('continue')
  end

  def when_i_click_to_change_my_answer
    click_link('Edit your answer')
  end

  def and_i_fill_in_an_answer
    scope = 'application_form.personal_statement'
    fill_in t('subject_knowledge.label', scope:), with: 'Hello world'
  end

  def then_i_can_check_my_answers
    expect(page).to have_content 'Your suitability to teach a subject or age group'
    expect(page).to have_content 'Hello world'
  end

  def then_i_should_see_validation_errors
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/subject_knowledge_form.attributes.subject_knowledge.blank')
  end

  def and_i_fill_in_a_different_answer
    scope = 'application_form.personal_statement'
    fill_in t('subject_knowledge.label', scope:), with: 'Hello world again'
  end

  def then_i_can_check_my_revised_answers
    expect(page).to have_content 'Your suitability to teach a subject or age group'
    expect(page).to have_content 'Hello world again'
  end

  def when_i_mark_the_section_as_completed
    choose t('application_form.completed_radio')
  end

  def and_i_submit_my_subject_knowledge
    click_button t('continue')
  end

  def when_i_click_on_continue
    and_i_submit_my_subject_knowledge
  end

  def then_i_see_a_section_complete_error
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/section_complete_form.attributes.completed.blank')
  end

  def then_i_should_see_the_form
    expect(page).to have_content(t('page_titles.subject_knowledge'))
  end

  def and_that_the_section_is_completed
    expect(page).to have_css('#your-suitability-to-teach-a-subject-or-age-group-badge-id', text: 'Completed')
  end

  def then_i_should_return_to_the_application
    expect(page).to have_content('Your application')
  end
end
