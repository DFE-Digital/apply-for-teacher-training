require 'rails_helper'

RSpec.feature 'Candidate is redirected correctly', skip: 'Update to continuous applications' do
  include CandidateHelper

  it 'Candidate reviews completed application and updates personal statement section' do
    given_i_am_signed_in
    when_i_have_completed_my_application
    and_i_review_my_application
    then_i_should_see_all_sections_are_complete

    when_i_click_change_on_my_personal_statement
    then_i_should_see_the_personal_statement_form

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_update_my_personal_statement
    then_i_should_be_redirected_to_the_application_review_page
    and_i_should_see_my_updated_personal_statement_response
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

  def when_i_click_change_on_my_personal_statement
    within('[data-qa="becoming-a-teacher"]') do
      click_link_or_button 'Edit your personal statement'
    end
  end

  def then_i_should_see_the_personal_statement_form
    expect(page).to have_current_path(candidate_interface_edit_becoming_a_teacher_path('return-to' => 'application-review'))
  end

  def when_i_click_back
    click_link_or_button 'Back'
  end

  def then_i_should_be_redirected_to_the_application_review_page
    expect(page).to have_current_path(candidate_interface_application_review_path)
  end

  def when_i_update_my_personal_statement
    when_i_click_change_on_my_personal_statement
    fill_in 'Your personal statement', with: 'All the dev jobs were taken.'
    click_link_or_button 'Continue'
  end

  def and_i_should_see_my_updated_personal_statement_response
    within('[data-qa="becoming-a-teacher"]') do
      expect(page).to have_content('All the dev jobs were taken.')
    end
  end
end
