require 'rails_helper'

RSpec.feature 'Candidate is redirected correctly' do
  include CandidateHelper

  scenario 'Candidate reviews completed application and updates adjustments section' do
    given_i_am_signed_in
    when_i_have_completed_my_application
    and_i_review_my_application
    then_i_should_see_all_sections_are_complete

    when_i_click_safeguarding_issues
    then_i_should_see_the_safeguarding_issues_form

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_update_safeguarding_issues
    then_i_should_be_redirected_to_the_application_review_page
    and_i_should_see_my_updated_safeguarding_issues
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def when_i_have_completed_my_application
    candidate_completes_application_form
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

  def and_i_visit_the_application_form_page
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_check_your_answers
    click_link 'Check and submit your application'
  end

  def when_i_click_safeguarding_issues
    within('[data-qa="safeguarding-issues"]') do
      click_link 'Change'
    end
  end

  def when_i_click_back
    click_link 'Back'
  end

  def then_i_should_be_redirected_to_the_application_review_page
    expect(page).to have_current_path(candidate_interface_application_review_path)
  end

  def then_i_should_see_the_safeguarding_issues_form
    expect(page).to have_current_path(candidate_interface_edit_safeguarding_path('return-to' => 'application-review'))
  end

  def when_i_update_safeguarding_issues
    when_i_click_safeguarding_issues
    choose 'No'
    click_button t('continue')
  end

  def and_i_should_see_my_updated_safeguarding_issues
    within('[data-qa="safeguarding-issues"]') do
      expect(page).to have_content('No')
    end
  end
end
