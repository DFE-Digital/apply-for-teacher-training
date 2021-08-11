require 'rails_helper'

RSpec.feature 'Candidate is redirected correctly' do
  include CandidateHelper

  scenario 'Candidate reviews completed application and updates unpaid experience section' do
    given_i_am_signed_in
    when_i_have_completed_my_application
    and_i_review_my_application
    then_i_should_see_all_sections_are_complete

    # each attribute is edited via the same form but have written system spec to
    # be scalable should they be separated

    # role
    when_i_click_change_role
    then_i_should_see_the_edit_role_form

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_update_the_role
    then_i_should_be_redirected_to_the_application_review_page
    and_i_should_see_the_updated_role

    # organisation
    when_i_click_change_organisation
    then_i_should_see_the_edit_role_form

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_update_the_organisation
    then_i_should_be_redirected_to_the_application_review_page
    and_i_should_see_the_updated_organisation

    # working with children
    when_i_click_change_working_with_children
    then_i_should_see_the_edit_role_form

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_update_working_with_children
    then_i_should_be_redirected_to_the_application_review_page
    and_i_should_see_updated_working_with_children

    # length
    when_i_click_change_length
    then_i_should_see_the_edit_role_form

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_update_the_length
    then_i_should_be_redirected_to_the_application_review_page
    and_i_should_see_the_updated_length

    # details
    when_i_click_change_details
    then_i_should_see_the_edit_role_form

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_update_the_details
    then_i_should_be_redirected_to_the_application_review_page
    and_i_should_see_the_updated_details
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

  def when_i_click_change_role
    within('[data-qa="volunteering-role"]') do
      click_link 'Change'
    end
  end

  def when_i_click_change_organisation
    within('[data-qa="volunteering-organisation"]') do
      click_link 'Change'
    end
  end

  def when_i_click_change_working_with_children
    within('[data-qa="volunteering-working-with-children"]') do
      click_link 'Change'
    end
  end

  def when_i_click_change_length
    within('[data-qa="volunteering-length"]') do
      click_link 'Change'
    end
  end

  def when_i_click_change_details
    within('[data-qa="volunteering-details"]') do
      click_link 'Change'
    end
  end

  def then_i_should_see_the_edit_role_form
    expect(page).to have_current_path(
      candidate_interface_edit_volunteering_role_path(
      current_candidate.application_forms.first.application_volunteering_experiences.first.id,
      'return-to' => 'application-review'
      )
    )
  end

  def when_i_click_back
    click_link 'Back'
  end

  def then_i_should_be_redirected_to_the_application_review_page
    expect(page).to have_current_path(candidate_interface_application_review_path)
  end

  def when_i_update_the_role
    when_i_click_change_role
    fill_in 'Your role', with: 'School Assistant'
    click_button 'Save and continue'
  end

  def when_i_update_the_organisation
    when_i_click_change_organisation
    fill_in 'Organisation where you gained experience or volunteered', with: 'Reigate Priory'
    click_button 'Save and continue'
  end

  def when_i_update_working_with_children
    when_i_click_change_working_with_children

    choose 'No'
    click_button 'Save and continue'
  end

  def when_i_update_the_length
    when_i_click_change_length

    within('[data-qa="start-date"]') do
      fill_in 'Month', with: '11'
    end

    click_button 'Save and continue'
  end

  def when_i_update_the_details
    when_i_click_change_details

    fill_in 'Enter details of your time commitment and responsibilities', with: 'Part time trainee'
    click_button 'Save and continue'
  end

  def and_i_should_see_the_updated_role
    within('[data-qa="volunteering-role"]') do
      expect(page).to have_content('School Assistant')
    end
  end

  def when_i_click_change_working_with_children
    within('[data-qa="volunteering-working-with-children"]') do
      click_link 'Change'
    end
  end

  def when_i_click_change_length
    within('[data-qa="volunteering-length"]') do
      click_link 'Change'
    end
  end

  def when_i_click_change_details
    within('[data-qa="volunteering-details"]') do
      click_link 'Change'
    end
  end

  def and_i_should_see_the_updated_organisation
    within('[data-qa="volunteering-organisation"]') do
      expect(page).to have_content('Reigate Priory')
    end
  end

  def and_i_should_see_updated_working_with_children
    within('[data-qa="volunteering-working-with-children"]') do
      expect(page).to have_content('No')
    end
  end

  def and_i_should_see_the_updated_length
    within('[data-qa="volunteering-length"]') do
      expect(page).to have_content('November')
    end
  end

  def and_i_should_see_the_updated_details
    within('[data-qa="volunteering-details"]') do
      expect(page).to have_content('Part time trainee')
    end
  end
end
