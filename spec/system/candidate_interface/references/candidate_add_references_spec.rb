require 'rails_helper'

RSpec.describe 'References' do
  include CandidateHelper

  scenario 'Candidate adds a new reference' do
    given_i_am_signed_in

    when_i_visit_the_site

    when_i_click_on_references_section
    then_i_see_the_review_references_page

    when_i_click_add_reference
    then_i_see_the_type_page

    when_i_click_continue_without_providing_a_type
    then_i_am_told_to_provide_a_type
    and_a_validation_error_is_logged_for_type

    when_i_select_academic
    and_i_click_continue
    then_i_see_the_referee_name_page

    when_i_click_save_and_continue_without_providing_a_name
    then_i_am_told_to_provide_a_name
    and_a_validation_error_is_logged_for_name

    when_i_fill_in_my_references_name
    and_i_click_save_and_continue

    when_i_click_save_and_continue_without_providing_an_emailing
    then_i_am_told_to_provide_an_email_address
    and_a_validation_error_is_logged_for_blank_email_address

    when_i_provide_an_email_address_with_an_invalid_format
    and_i_click_save_and_continue
    then_i_am_told_my_email_address_needs_a_valid_format
    and_a_validation_error_is_logged_for_invalid_email_address

    when_i_provide_a_valid_email_address
    and_i_click_save_and_continue
    then_i_see_the_relationship_page

    when_i_click_save_and_continue_without_providing_a_relationship
    then_i_am_told_to_provide_a_relationship
    and_a_validation_error_is_logged_for_relationship

    when_i_fill_in_my_references_relationship
    and_i_click_save_and_continue
    and_i_see_my_references_details
    then_i_see_the_review_references_page

    when_i_click_change_on_the_references_name
    and_i_input_a_new_name
    and_i_click_save_and_continue
    then_i_see_the_updated_name
    then_i_see_the_review_references_page

    when_i_click_change_on_email_address
    and_i_input_a_new_email_address
    and_i_click_save_and_continue
    then_i_see_the_updated_email_address
    then_i_see_the_review_references_page

    when_i_click_change_on_the_reference_type
    and_i_choose_professional
    and_i_click_continue
    then_i_see_the_updated_type
    then_i_see_the_review_references_page

    when_i_click_change_on_relationship
    and_i_input_my_relationship_to_the_referee
    and_i_click_save_and_continue
    then_i_see_the_updated_relationship
    then_i_see_the_review_references_page
    and_i_see_my_reference

    when_i_try_to_edit_someone_elses_reference
    then_i_see_the_review_references_page

    when_i_try_and_edit_a_reference_that_does_not_exist
    then_i_see_the_review_references_page
    and_i_do_not_see_the_complete_section

    when_i_click_to_add_another_reference
    when_i_select_academic
    and_i_click_continue
    when_i_fill_in_my_second_references_name
    and_i_click_save_and_continue
    when_i_provide_a_second_valid_email_address
    and_i_click_save_and_continue
    when_i_fill_in_my_second_references_relationship
    and_i_click_save_and_continue
    then_i_see_the_review_references_page

    and_i_see_the_complete_section
    when_i_mark_the_section_as_complete
    then_i_am_redirected_to_my_application_or_details
    and_the_references_section_is_marked_as_completed

    when_i_click_on_references_section
    and_i_delete_the_second_referee
    then_my_application_references_are_incomplete
    and_i_do_not_see_the_complete_section
  end

  def given_i_am_signed_in
    given_i_am_signed_in_with_one_login
    @application = @current_candidate.current_application
  end

  def when_i_visit_the_site
    visit candidate_interface_details_path
  end

  def when_i_click_on_references_section
    click_link_or_button 'References'
  end

  def when_i_click_add_reference
    click_link_or_button 'Add reference'
  end

  def when_i_click_to_add_another_reference
    click_link_or_button 'Add another reference'
  end

  def then_i_see_the_type_page
    expect(page).to have_current_path candidate_interface_references_type_path
  end

  def when_i_click_continue_without_providing_a_type
    and_i_click_continue
  end

  def then_i_am_told_to_provide_a_type
    expect(page).to have_content('Choose a type of referee')
  end

  def and_a_validation_error_is_logged_for_type
    expect(ValidationError.count).to be 1
  end

  def when_i_select_academic
    choose 'Academic, such as a university tutor'
  end

  def and_i_click_save_and_continue
    click_link_or_button t('save_and_continue')
  end

  def and_i_click_continue
    click_link_or_button t('continue')
  end

  def then_i_see_the_referee_name_page
    expect(page).to have_current_path candidate_interface_references_name_path('academic')
  end

  def when_i_click_save_and_continue_without_providing_a_name
    and_i_click_save_and_continue
  end

  def then_i_am_told_to_provide_a_name
    expect(page).to have_content('Enter the name of the person who can give a reference')
  end

  def and_a_validation_error_is_logged_for_name
    expect(ValidationError.count).to be 2
  end

  def when_i_fill_in_my_references_name
    fill_in 'candidate-interface-reference-referee-name-form-name-field-error', with: 'Walter White'
    and_i_click_save_and_continue
  end

  def when_i_fill_in_my_second_references_name
    fill_in 'What’s the name of the person who can give a reference?', with: 'John Doe'
  end

  def when_i_provide_a_second_valid_email_address
    fill_in 'What is John Doe’s email address?', with: 'johndoe@example.com'
  end

  def when_i_fill_in_my_second_references_relationship
    fill_in 'How do you know John Doe and how long have you known them?', with: 'He is my singing teacher?'
  end

  def then_i_see_the_referee_email_page
    expect(page).to have_current_path candidate_interface_references_email_address_path(@application.application_references.creation_order.last.id)
  end

  def when_i_click_save_and_continue_without_providing_an_emailing
    and_i_click_save_and_continue
  end

  def then_i_am_told_to_provide_an_email_address
    expect(page).to have_content('Enter their email address')
  end

  def and_a_validation_error_is_logged_for_blank_email_address
    expect(ValidationError.count).to be 4
  end

  def when_i_provide_an_email_address_with_an_invalid_format
    fill_in 'candidate-interface-reference-referee-email-address-form-email-address-field-error', with: 'invalid.email.address'
  end

  def then_i_am_told_my_email_address_needs_a_valid_format
    expect(page).to have_content('Enter an email address in the correct format, like name@example.com')
  end

  def and_a_validation_error_is_logged_for_invalid_email_address
    expect(ValidationError.count).to be 5
  end

  def when_i_provide_a_valid_email_address
    fill_in 'candidate-interface-reference-referee-email-address-form-email-address-field-error', with: 'iamtheone@whoknocks.com'
  end

  def then_i_see_the_relationship_page
    expect(page).to have_current_path candidate_interface_references_relationship_path(@application.application_references.creation_order.last.id)
  end

  def when_i_click_save_and_continue_without_providing_a_relationship
    and_i_click_save_and_continue
  end

  def then_i_am_told_to_provide_a_relationship
    expect(page).to have_content('Enter how you know them and for how long')
  end

  def and_a_validation_error_is_logged_for_relationship
    expect(ValidationError.count).to be 6
  end

  def when_i_fill_in_my_references_relationship
    fill_in 'candidate-interface-reference-referee-relationship-form-relationship-field-error', with: 'Through nefarious behaviour.'
  end

  def and_i_see_my_references_details
    expect(page).to have_content('Academic')
    expect(page).to have_content('Walter White')
    expect(page).to have_content('iamtheone@whoknocks.com')
    expect(page).to have_content('Through nefarious behaviour.')
  end

  def when_i_click_change_on_the_references_name
    click_link_or_button 'Change name for Walter White'
  end

  def and_i_input_a_new_name
    fill_in 'What’s the name of the person who can give a reference?', with: 'Jessie Pinkman'
  end

  def then_i_see_the_updated_name
    expect(page).to have_content('Jessie Pinkman')
  end

  def when_i_click_change_on_email_address
    click_link_or_button 'Change email address for Jessie Pinkman'
  end

  def and_i_input_a_new_email_address
    fill_in 'candidate-interface-reference-referee-email-address-form-email-address-field', with: 'jessie@pinkman.com'
  end

  def then_i_see_the_updated_email_address
    expect(page).to have_content('jessie@pinkman.com')
  end

  def when_i_click_change_on_the_reference_type
    click_link_or_button 'Change reference type for Jessie Pinkman'
  end

  def and_i_choose_professional
    choose 'Professional, such as a manager'
  end

  def then_i_see_the_updated_type
    expect(page).to have_content('Professional')
  end

  def when_i_click_change_on_relationship
    click_link_or_button 'Change relationship for Jessie Pinkman'
  end

  def and_i_input_my_relationship_to_the_referee
    fill_in 'candidate-interface-reference-referee-relationship-form-relationship-field', with: 'I sold him a moterhome.'
  end

  def then_i_see_the_updated_relationship
    expect(page).to have_content('I sold him a moterhome.')
  end

  def then_i_see_the_review_references_page
    expect(page).to have_current_path candidate_interface_references_review_path
  end

  def and_i_see_my_reference
    expect(page).to have_content('Professional')
    expect(page).to have_content('Jessie Pinkman')
    expect(page).to have_content('jessie@pinkman.com')
    expect(page).to have_content('I sold him a moterhome.')
  end

  def when_i_try_to_edit_someone_elses_reference
    non_associated_reference = create(:reference, :not_requested_yet)
    visit candidate_interface_references_edit_name_path(non_associated_reference.id)
  end

  def when_i_try_and_edit_a_reference_that_does_not_exist
    visit candidate_interface_references_edit_name_path('INVALID')
  end

  def and_i_choose_to_submit_my_reference_now
    choose 'Yes, send a reference request now'
  end

  def then_i_see_the_candidate_name_page
    expect(page).to have_current_path candidate_interface_references_create_candidate_name_path(@application.application_references.creation_order.last.id)
  end

  def and_i_am_told_my_reference_request_has_been_sent
    expect(page).to have_content('Reference request sent to Jessie Pinkman')
  end

  def and_i_do_not_see_the_complete_section
    expect(page).to have_no_content('Have you completed this section?')
    expect(page).to have_no_content('Yes, I have completed this section')
    expect(page).to have_no_content('No, I’ll come back to it later')
  end

  def and_i_see_the_complete_section
    expect(page).to have_content('Have you completed this section?')
    expect(page).to have_content('Yes, I have completed this section')
    expect(page).to have_content('No, I’ll come back to it later')
  end

  def when_i_mark_the_section_as_complete
    choose 'Yes, I have completed this section'
    click_link_or_button 'Continue'
  end

  def and_the_references_section_is_marked_as_completed
    expect(safeguarding_section.text.downcase).to include('references to be requested if you accept an offer completed')
  end

  def then_i_am_redirected_to_my_application_or_details
    expect(page).to have_current_path candidate_interface_details_path
  end

  def and_i_delete_the_second_referee
    when_i_click_delete_referre_on_my_second_referee
    and_i_confirm_the_deletion
  end

  def when_i_click_delete_referre_on_my_second_referee
    page.all('.app-summary-card__actions-list-item a').last.click
  end

  def and_i_confirm_the_deletion
    click_link_or_button 'Yes I’m sure - delete this reference'
  end

  def then_my_application_references_are_incomplete
    expect(@application.reload.references_completed).to be false
    click_link_or_button 'Back to your details'
    expect(safeguarding_section.text.downcase).to include('references to be requested if you accept an offer incomplete')
  end

  def safeguarding_section
    find(:xpath, "//h2[contains(text(),'Safeguarding')]/..")
  end
end
