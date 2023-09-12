require 'rails_helper'

RSpec.feature 'Candidate is redirected correctly', continuous_applications: false do
  include CandidateHelper

  it 'Candidate reviews completed application and updates references section' do
    given_i_am_signed_in
    when_i_have_completed_my_application_and_have_2_references
    and_i_review_my_application
    then_i_should_see_all_sections_are_complete
    and_i_should_see_my_two_references

    when_i_click_change_references_name
    then_i_should_see_the_references_name_form
    and_the_back_link_should_point_to_application_review
    and_i_click_save_and_continue
    then_i_should_be_redirected_to_the_application_review_page

    when_i_click_change_references_type
    then_i_should_see_the_references_type_form
    and_the_back_link_should_point_to_application_review
    and_i_click_continue
    then_i_should_be_redirected_to_the_application_review_page

    when_i_click_change_references_email
    then_i_should_see_the_references_email_form
    and_the_back_link_should_point_to_application_review
    and_i_click_save_and_continue

    when_i_click_change_references_relationship
    then_i_should_see_the_references_relationship_form
    and_the_back_link_should_point_to_application_review
    and_i_click_save_and_continue
    then_i_should_be_redirected_to_the_application_review_page
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def when_i_have_completed_my_application_and_have_2_references
    candidate_completes_application_form(with_referees: false)

    @first_reference = create(:reference, :not_requested_yet, application_form: @current_candidate.current_application)
    @second_reference = create(:reference, :feedback_provided, application_form: @current_candidate.current_application)
    @current_candidate.current_application.update(references_completed: true)
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

  def when_i_click_change_references_name
    reference_link(/^Change name for #{@first_reference.name}/).click
  end

  def when_i_click_change_references_type
    reference_link(/^Change reference type for #{@first_reference.name}/).click
  end

  def when_i_click_change_references_email
    reference_link(/^Change email address for #{@first_reference.name}/).click
  end

  def when_i_click_change_references_relationship
    reference_link(/^Change relationship for #{@first_reference.name}/).click
  end

  def and_i_should_see_my_two_references
    safeguarding = find(:xpath, "//h2[contains(text(),'Safeguarding')]/..")

    expect(safeguarding).to have_content @first_reference.name
    expect(safeguarding).to have_content @second_reference.name
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

  def when_i_click_back
    click_link 'Back to application'
  end

  def then_i_should_be_redirected_to_the_application_review_page
    expect(page).to have_current_path(candidate_interface_application_review_path)
  end

  def when_i_update_my_references
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

  def then_i_should_see_the_references_name_form
    expect(page).to have_current_path(
      candidate_interface_references_edit_name_path(@first_reference.id, return_to: 'application-review'),
    )
  end

  def then_i_should_see_the_references_type_form
    expect(page).to have_current_path(
      candidate_interface_references_edit_type_path(@first_reference.referee_type, @first_reference.id, return_to: 'application-review'),
    )
  end

  def then_i_should_see_the_references_email_form
    expect(page).to have_current_path(
      candidate_interface_references_edit_email_address_path(@first_reference.id, return_to: 'application-review'),
    )
  end

  def then_i_should_see_the_references_relationship_form
    expect(page).to have_current_path(
      candidate_interface_references_edit_relationship_path(@first_reference.id, return_to: 'application-review'),
    )
  end

  def and_the_back_link_should_point_to_application_review
    expect(page.find('a', text: 'Back')[:href]).to eq(candidate_interface_application_review_path)
  end

  def and_i_click_save_and_continue
    click_on 'Save and continue'
  end

  def and_i_click_continue
    click_on 'Continue'
  end

  def reference_link(text)
    safeguarding_section.find('a', text:)
  end

  def safeguarding_section
    find(:xpath, "//h2[contains(text(),'Safeguarding')]/..")
  end
end
