require 'rails_helper'

RSpec.feature 'Candidate is redirected correctly' do
  include CandidateHelper

  scenario 'Candidate reviews completed application and updates personal details section' do
    given_i_am_signed_in
    when_i_have_completed_my_application_and_have_3_references
    and_i_review_my_application
    then_i_should_see_all_sections_are_complete
    and_i_should_see_my_two_selected_references

    when_i_click_change_references
    then_i_should_see_the_select_references_form

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_update_my_selected_references
    then_i_should_be_redirected_to_the_application_review_page
    and_i_should_see_my_updated_references
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def when_i_have_completed_my_application_and_have_3_references
    candidate_completes_application_form
    @current_candidate.current_application.application_references.each do |reference|
      reference.update!(feedback_status: :feedback_provided, selected: true)
    end
    @first_reference = @current_candidate.current_application.application_references.selected.first
    @second_reference = @current_candidate.current_application.application_references.selected.second
    @third_reference = create(:reference, :feedback_provided, selected: false, application_form: @current_candidate.current_application)
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

  def and_i_should_see_my_two_selected_references
    within('[data-qa="selected-references"]') do
      expect(page).to have_content @first_reference.name
      expect(page).to have_content @second_reference.name
      expect(page).not_to have_content @third_reference.name
    end
  end

  def and_i_visit_the_application_form_page
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_check_your_answers
    click_link 'Check and submit your application'
  end

  def when_i_click_change_references
    within('[data-qa="selected-references"]') do
      click_link 'Change'
    end
  end

  def then_i_should_see_the_select_references_form
    expect(page).to have_current_path(candidate_interface_select_references_path('return-to' => 'application-review'))
  end

  def when_i_click_back
    click_link 'Back to application'
  end

  def then_i_should_be_redirected_to_the_application_review_page
    expect(page).to have_current_path(candidate_interface_application_review_path)
  end

  def when_i_update_my_selected_references
    when_i_click_change_references
    uncheck @second_reference.name
    check @third_reference.name
    click_button 'Save and continue'
  end

  def and_i_should_see_my_updated_references
    within('[data-qa="selected-references"]') do
      expect(page).to have_content @first_reference.name
      expect(page).to have_content @third_reference.name
      expect(page).not_to have_content @second_reference.name
    end
  end
end
