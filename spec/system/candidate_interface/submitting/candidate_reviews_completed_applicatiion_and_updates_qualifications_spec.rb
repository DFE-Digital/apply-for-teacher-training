require 'rails_helper'

RSpec.feature 'Candidate is redirected correctly' do
  include CandidateHelper

  scenario 'Candidate reviews completed application and updates qualification details section' do
    given_i_am_signed_in
    when_i_have_completed_my_application
    and_i_review_my_application
    then_i_should_see_all_sections_are_complete

    # GCSE English qualification
    when_i_click_change_english_gcse_qualification
    then_i_should_see_the_gcse_type_form

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_update_english_gcse_qualification
    then_i_should_be_redirected_to_the_application_review_page
    and_i_should_see_my_updated_gcse_qualification

    # GCSE English grade
    when_i_click_change_english_gcse_grade
    then_i_should_see_the_gcse_grade_form

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_update_english_gcse_grade
    then_i_should_be_redirected_to_the_application_review_page
    and_i_should_see_my_updated_gcse_grade

    # GCSE English year awarded
    when_i_click_change_english_gcse_year
    then_i_should_see_the_gcse_year_form

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_update_english_gcse_year
    then_i_should_be_redirected_to_the_application_review_page
    and_i_should_see_my_updated_gcse_year
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def when_i_have_completed_my_application
    candidate_completes_application_form
    @current_candidate.current_application.application_references.each do |reference|
      reference.update!(feedback_status: :feedback_provided)
    end
  end

  def and_i_visit_the_application_form_page
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_check_your_answers
    click_link 'Check and submit your application'
  end

  def and_i_review_my_application
    allow(LanguagesSectionPolicy).to receive(:hide?).and_return(false)
    and_i_visit_the_application_form_page
    when_i_click_on_check_your_answers
  end

  def then_i_should_see_all_sections_are_complete
    application_form_sections.each do |section|
      expect(page).not_to have_selector "[data-qa='incomplete-#{section}']"
    end
  end

  def when_i_click_back
    click_link 'Back'
  end

  def then_i_should_be_redirected_to_the_application_review_page
    expect(page).to have_current_path(candidate_interface_application_review_path)
  end

  def when_i_click_change_english_gcse_qualification
    within('[data-qa="gcse-english-qualification"]') do
      click_link 'Change'
    end
  end

  def when_i_click_change_english_gcse_grade
    within('[data-qa="gcse-english-grade"]') do
      click_link 'Change'
    end
  end

  def when_i_click_change_english_gcse_year
    within('[data-qa="gcse-english-award-year"]') do
      click_link 'Change'
    end
  end

  def then_i_should_see_the_gcse_type_form
    expect(page).to have_current_path(candidate_interface_gcse_details_edit_type_path(subject: 'english', 'return-to' => 'application-review'))
  end

  def then_i_should_see_the_gcse_grade_form
    expect(page).to have_current_path(candidate_interface_edit_gcse_english_grade_path('return-to' => 'application-review'))
  end

  def then_i_should_see_the_gcse_year_form
    expect(page).to have_current_path(candidate_interface_gcse_details_edit_year_path(subject: 'english', 'return-to' => 'application-review'))
  end

  def when_i_update_english_gcse_qualification
    when_i_click_change_english_gcse_qualification

    choose 'O level'
    click_button t('save_and_continue')
  end

  def when_i_update_english_gcse_grade
    when_i_click_change_english_gcse_grade
    fill_in 'Please specify your grade', with: 'C'

    click_button t('save_and_continue')
  end

  def when_i_update_english_gcse_year
    when_i_click_change_english_gcse_year
    fill_in 'Enter year', with: '1980j'

    click_button t('save_and_continue')
  end

  def and_i_should_see_my_updated_gcse_qualification
    within('[data-qa="gcse-english-grade"]') do
      expect(page).to have_content('O level')
    end
  end

  def and_i_should_see_my_updated_gcse_grade
    within('[data-qa="gcse-english-qualification"]') do
      expect(page).to have_content('O level')
    end
  end

  def and_i_should_see_my_updated_gcse_year
    within('[data-qa="gcse-english-award-year"]') do
      expect(page).to have_content('1980')
    end
  end
end
