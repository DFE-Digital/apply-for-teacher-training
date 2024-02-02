require 'rails_helper'

RSpec.feature 'Candidate is redirected correctly', skip: 'Update to continuous applications' do
  include CandidateHelper

  it 'Candidate reviews completed application and updates adjustments section' do
    given_i_am_signed_in
    when_i_have_completed_my_application
    and_i_review_my_application
    then_i_should_see_all_sections_are_complete

    # asking for support
    when_i_click_ask_for_support
    then_i_should_see_the_ask_for_support_form

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_update_ask_for_support_status
    then_i_should_be_redirected_to_the_application_review_page
    and_i_should_see_my_updated_ask_for_support_status

    # interview needs
    when_i_click_interview_needs
    then_i_should_see_the_interview_needs_form

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_update_interview_needs
    then_i_should_be_redirected_to_the_application_review_page
    and_i_should_see_my_updated_interview_needs
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def when_i_have_completed_my_application
    candidate_completes_application_form
  end

  def and_i_review_my_application
    and_i_visit_the_application_form_page
    when_i_click_on_check_your_answers
  end

  def then_i_should_see_all_sections_are_complete
    application_form_sections.each do |section|
      expect(page).to have_no_css "[data-qa='incomplete-#{section}']"
    end
  end

  def and_i_visit_the_application_form_page
    visit candidate_interface_continuous_applications_details_path
  end

  def when_i_click_on_check_your_answers
    click_link_or_button 'Check and submit your application'
  end

  def when_i_click_ask_for_support
    within('[data-qa="adjustments-support-confirmation"]') do
      click_link_or_button 'Change'
    end
  end

  def when_i_click_interview_needs
    summary = first('[data-qa="adjustments-interview-preferences"]')
    within(summary) do
      click_link_or_button 'Change'
    end
  end

  def then_i_should_see_the_ask_for_support_form
    expect(page).to have_content('Ask for support if you’re disabled')
  end

  def then_i_should_see_the_interview_needs_form
    expect(page).to have_content('Interview availability')
  end

  def then_i_should_be_redirected_to_the_application_review_page
    expect(page).to have_current_path(candidate_interface_application_review_path)
  end

  def when_i_click_back
    click_link_or_button 'Back'
  end

  def when_i_update_ask_for_support_status
    when_i_click_ask_for_support
    choose 'No'
    click_link_or_button t('continue')
  end

  def when_i_update_interview_needs
    when_i_click_interview_needs
    choose 'No'
    click_link_or_button t('save_and_continue')
  end

  def and_i_should_see_my_updated_ask_for_support_status
    within('[data-qa="adjustments-support-confirmation"]') do
      expect(page).to have_content('No')
    end
  end

  def and_i_should_see_my_updated_interview_needs
    within('[data-qa="adjustments-interview-preferences"]') do
      expect(page).to have_content('No')
    end
  end
end
