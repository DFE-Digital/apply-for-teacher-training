require 'rails_helper'

RSpec.feature 'Review references' do
  include CandidateHelper

  scenario 'the candidate has several references in different states' do
    given_i_am_signed_in
    and_the_decoupled_references_flag_is_on
    when_i_view_my_application
    then_the_references_section_is_incomplete

    when_i_have_added_references
    then_the_references_section_is_still_incomplete

    when_enough_references_have_been_given
    then_the_references_section_is_complete
    and_i_can_review_my_references_before_submission
    and_i_can_edit_a_reference
    and_i_can_delete_a_reference
    and_i_can_return_to_the_application_page
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_the_decoupled_references_flag_is_on
    FeatureFlag.activate('decoupled_references')
  end

  def when_i_view_my_application
    visit candidate_interface_application_form_path
  end

  def then_the_references_section_is_incomplete
    when_i_view_my_application
    within '#add-your-references-badge-id' do
      expect(page).to have_content 'Incomplete'
    end
  end

  def then_the_references_section_is_still_incomplete
    when_i_view_my_application
    within '#manage-your-references-badge-id' do
      expect(page).to have_content 'In progress'
    end
  end

  def when_i_have_added_references
    application_form = current_candidate.current_application
    @complete_reference = create(:reference, :complete, application_form: application_form)
    @not_sent_reference = create(:reference, :unsubmitted, application_form: application_form)
    @requested_reference = create(:reference, :requested, application_form: application_form)
    @refused_reference = create(:reference, :refused, application_form: application_form)
  end

  def when_enough_references_have_been_given
    create(:reference, :complete, application_form: current_candidate.current_application)
  end

  def then_the_references_section_is_complete
    when_i_view_my_application
    within '#review-your-references-badge-id' do
      expect(page).to have_content 'Complete'
    end
  end

  def and_i_can_review_my_references_before_submission
    click_link 'Review your references'
    expect(page).to have_current_path candidate_interface_decoupled_references_review_path

    within '#references_given' do
      expect(page).to have_content @complete_reference.email_address
      expect(page).not_to have_link 'Change'
      expect(page).not_to have_link 'Delete referee'
    end

    within '#references_waiting_to_be_sent' do
      expect(page).to have_content @not_sent_reference.email_address
      expect(page).to have_link 'Change'
      expect(page).to have_link 'Delete referee'
    end

    within '#references_sent' do
      expect(page).to have_content @requested_reference.email_address
      expect(page).to have_content @refused_reference.email_address
      expect(page).not_to have_link 'Change'
      expect(page).not_to have_link 'Delete referee'
    end
  end

  def and_i_can_edit_a_reference
    within '#references_waiting_to_be_sent' do
      click_link 'Change name'
    end

    fill_in 'candidate-interface-reference-referee-name-form-name-field', with: 'John Major'
    click_button 'Save and continue'

    within '#references_waiting_to_be_sent' do
      expect(page).to have_content 'John Major'
    end

    expect(page).to have_current_path candidate_interface_decoupled_references_review_path
  end

  def and_i_can_delete_a_reference
    within '#references_waiting_to_be_sent' do
      click_link 'Delete referee'
    end
    click_button 'Yes I’m sure'

    expect(page).to have_current_path candidate_interface_decoupled_references_review_path
    expect(page).not_to have_css('#references_waiting_to_be_sent')
    expect(page).not_to have_link 'Delete referee'
  end

  def and_i_can_return_to_the_application_page
    click_link 'Continue'
    expect(page).to have_current_path candidate_interface_application_form_path
  end
end
