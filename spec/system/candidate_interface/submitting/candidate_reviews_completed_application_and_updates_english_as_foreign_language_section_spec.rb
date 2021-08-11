require 'rails_helper'

RSpec.feature 'Candidate is redirected correctly' do
  include CandidateHelper
  include EFLHelper

  scenario 'Candidate reviews completed application and updates English as a foreign language section' do
    given_i_am_signed_in
    when_i_have_completed_my_application
    and_i_review_my_application
    then_i_should_see_all_sections_are_complete

    when_i_click_change_on_efl
    then_i_should_see_the_efl_form

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_change_efl_response_and_enter_toefl_details
    then_i_should_be_redirected_to_the_application_review_page

    when_i_change_toefl_score
    then_i_should_be_redirected_to_the_application_review_page
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def when_i_have_completed_my_application
    candidate_completes_application_form(international: true)

    @current_candidate.current_application.application_references.each do |reference|
      reference.update!(feedback_status: :feedback_provided)
    end
  end

  def and_i_review_my_application
    and_i_visit_the_application_form_page
    when_i_click_on_check_your_answers
  end

  def then_i_should_see_all_sections_are_complete
    application_form_sections.each do |section|
      expect(page).not_to have_selector "[data-qa='incomplete-#{section}']"
    end
  end

  def and_i_visit_the_application_form_page
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_check_your_answers
    click_link 'Check and submit your application'
  end

  def when_i_click_change_on_efl
    within('[data-qa="english-as-a-foreign-language"]') do
      click_link 'Change'
    end
  end

  def then_i_should_see_the_efl_form
    expect(page).to have_current_path(candidate_interface_english_foreign_language_edit_start_path('return-to' => 'application-review'))
  end

  def when_i_click_back
    click_link 'Back'
  end

  def then_i_should_be_redirected_to_the_application_review_page
    expect(page).to have_current_path(candidate_interface_application_review_path)
  end

  def when_i_change_efl_response_and_enter_toefl_details
    when_i_click_change_on_efl
    choose 'Yes'
    click_button 'Continue'
    choose 'Test of English as a Foreign Language'
    click_button 'Continue'
    fill_in 'Total score', with: '95'
    fill_in 'TOEFL registration number', with: '0000 0000 1234 5678'
    fill_in 'When did you complete the assessment?', with: '2010'
    click_button 'Save and continue'
    choose 'Yes, I have completed this section'
    click_button 'Continue'
  end

  def when_i_change_toefl_score
    when_i_click_change_on_efl_score
    fill_in 'Total score', with: '85'
    click_button 'Save and continue'
    choose 'Yes, I have completed this section'
    click_button 'Continue'
  end

  def when_i_click_change_on_efl_score
    within('[data-qa="english-as-a-foreign-language-total-score"]') do
      click_link 'Change'
    end
  end
end
