require 'rails_helper'

RSpec.feature 'References' do
  include CandidateHelper

  scenario 'Candidate adds a new reference' do
    given_i_am_signed_in

    when_i_visit_the_site
    then_i_should_see_the_references_section

    when_i_click_add_you_references
    then_i_see_the_start_page

    when_i_click_continue
    then_i_see_the_type_page

    when_i_click_continue_without_providing_a_type
    then_i_should_be_told_to_provide_a_type
    and_a_validation_error_is_logged_for_type

    when_i_select_academic
    and_i_click_continue
    then_i_should_see_the_referee_name_page

    when_i_click_save_and_continue_without_providing_a_name
    then_i_should_be_told_to_provide_a_name
    and_a_validation_error_is_logged_for_name

    when_i_fill_in_my_references_name
    and_i_click_save_and_continue

    when_i_click_save_and_continue_without_providing_an_emailing
    then_i_should_be_told_to_provide_an_email_address
    and_a_validation_error_is_logged_for_blank_email_address

    when_i_provide_an_email_address_with_an_invalid_format
    and_i_click_save_and_continue
    then_i_am_told_my_email_address_needs_a_valid_format
    and_a_validation_error_is_logged_for_invalid_email_address

    when_i_provide_a_valid_email_address
    and_i_click_save_and_continue
    then_i_see_the_relationship_page

    when_i_click_save_and_continue_without_providing_a_relationship
    then_i_should_be_told_to_provide_a_relationship
    and_a_validation_error_is_logged_for_relationship

    when_i_fill_in_my_references_relationship
    and_i_click_save_and_continue
    then_i_should_see_the_review_unsubmitted_page
    and_i_should_see_my_references_details

    when_i_click_change_on_the_references_name
    and_i_input_a_new_name
    and_i_click_save_and_continue
    then_i_see_the_updated_name

    when_i_click_change_on_email_address
    and_i_input_a_new_email_address
    and_i_click_save_and_continue
    then_i_see_the_updated_email_address

    when_i_click_change_on_the_reference_type
    and_i_choose_professional
    and_i_click_continue
    then_i_see_the_updated_type

    when_i_click_change_on_relationship
    and_i_input_my_relationship_to_the_referee
    and_i_click_save_and_continue
    then_i_see_the_updated_relationship

    when_i_choose_that_im_not_ready_to_submit_my_reference
    and_i_click_save_and_continue
    then_i_see_the_review_references_page
    and_i_should_see_my_reference

    when_i_try_to_edit_someone_elses_reference
    then_i_see_the_review_references_page

    when_i_try_and_edit_a_reference_that_does_not_exist
    then_i_see_the_review_references_page

    when_i_visit_the_unsubmitted_reference_page
    and_i_choose_to_submit_my_reference_now
    and_i_click_save_and_continue
    then_i_see_the_candidate_name_page

    when_i_visit_the_unsubmitted_reference_page
    and_i_have_added_my_name_to_the_application_form
    and_i_choose_to_submit_my_reference_now
    and_i_click_save_and_continue
    then_i_see_the_review_references_page
    and_i_should_be_told_my_reference_request_has_been_sent
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
    @application = @candidate.current_application
  end

  def when_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def then_i_should_see_the_references_section
    expect(page).to have_content 'It takes 8 days to get a reference on average.'
  end

  def when_i_click_add_you_references
    click_link 'Add your references'
  end

  def then_i_see_the_start_page
    expect(page).to have_current_path candidate_interface_references_start_path
  end

  def when_i_click_continue
    click_link t('continue')
  end

  def then_i_see_the_type_page
    expect(page).to have_current_path candidate_interface_references_type_path
  end

  def when_i_click_continue_without_providing_a_type
    and_i_click_continue
  end

  def then_i_should_be_told_to_provide_a_type
    expect(page).to have_content 'Choose a type of referee'
  end

  def and_a_validation_error_is_logged_for_type
    expect(ValidationError.count).to be 1
  end

  def when_i_select_academic
    choose 'Academic'
  end

  def and_i_click_save_and_continue
    click_button t('save_and_continue')
  end

  def and_i_click_continue
    click_button t('continue')
  end

  def then_i_should_see_the_referee_name_page
    expect(page).to have_current_path candidate_interface_references_name_path('academic')
  end

  def when_i_click_save_and_continue_without_providing_a_name
    and_i_click_save_and_continue
  end

  def then_i_should_be_told_to_provide_a_name
    expect(page).to have_content 'Enter your referee’s name'
  end

  def and_a_validation_error_is_logged_for_name
    expect(ValidationError.count).to be 2
  end

  def when_i_fill_in_my_references_name
    fill_in 'candidate-interface-reference-referee-name-form-name-field-error', with: 'Walter White'
    and_i_click_save_and_continue
  end

  def then_i_see_the_referee_email_page
    expect(page).to have_current_path candidate_interface_references_email_address_path(@application.application_references.last.id)
  end

  def when_i_click_save_and_continue_without_providing_an_emailing
    and_i_click_save_and_continue
  end

  def then_i_should_be_told_to_provide_an_email_address
    expect(page).to have_content 'Enter your referee’s email address'
  end

  def and_a_validation_error_is_logged_for_blank_email_address
    expect(ValidationError.count).to be 4
  end

  def when_i_provide_an_email_address_with_an_invalid_format
    fill_in 'candidate-interface-reference-referee-email-address-form-email-address-field-error', with: 'invalid.email.address'
  end

  def then_i_am_told_my_email_address_needs_a_valid_format
    expect(page).to have_content 'Enter an email address in the correct format, like name@example.com'
  end

  def and_a_validation_error_is_logged_for_invalid_email_address
    expect(ValidationError.count).to be 5
  end

  def when_i_provide_a_valid_email_address
    fill_in 'candidate-interface-reference-referee-email-address-form-email-address-field-error', with: 'iamtheone@whoknocks.com'
  end

  def then_i_see_the_relationship_page
    expect(page).to have_current_path candidate_interface_references_relationship_path(@application.application_references.last.id)
  end

  def when_i_click_save_and_continue_without_providing_a_relationship
    and_i_click_save_and_continue
  end

  def then_i_should_be_told_to_provide_a_relationship
    expect(page).to have_content 'Enter how you know this referee and for how long'
  end

  def and_a_validation_error_is_logged_for_relationship
    expect(ValidationError.count).to be 6
  end

  def when_i_fill_in_my_references_relationship
    fill_in 'candidate-interface-reference-referee-relationship-form-relationship-field-error', with: 'Through nefarious behaviour.'
  end

  def then_i_should_see_the_review_unsubmitted_page
    expect(page).to have_current_path candidate_interface_references_review_unsubmitted_path(@application.application_references.last.id)
  end

  def and_i_should_see_my_references_details
    expect(page).to have_content 'Academic'
    expect(page).to have_content 'Walter White'
    expect(page).to have_content 'iamtheone@whoknocks.com'
    expect(page).to have_content 'Through nefarious behaviour.'
  end

  def when_i_click_change_on_the_references_name
    page.all('.govuk-summary-list__actions')[0].click_link
  end

  def and_i_input_a_new_name
    fill_in 'candidate-interface-reference-referee-name-form-name-field', with: 'Jessie Pinkman'
  end

  def then_i_see_the_updated_name
    expect(page).to have_content 'Jessie Pinkman'
  end

  def when_i_click_change_on_email_address
    page.all('.govuk-summary-list__actions')[1].click_link
  end

  def and_i_input_a_new_email_address
    fill_in 'candidate-interface-reference-referee-email-address-form-email-address-field', with: 'jessie@pinkman.com'
  end

  def then_i_see_the_updated_email_address
    expect(page).to have_content 'jessie@pinkman.com'
  end

  def when_i_click_change_on_the_reference_type
    page.all('.govuk-summary-list__actions')[2].click_link
  end

  def and_i_choose_professional
    choose 'Character'
  end

  def then_i_see_the_updated_type
    expect(page).to have_content 'Character'
  end

  def when_i_click_change_on_relationship
    page.all('.govuk-summary-list__actions')[3].click_link
  end

  def and_i_input_my_relationship_to_the_referee
    fill_in 'candidate-interface-reference-referee-relationship-form-relationship-field', with: 'I sold him a moterhome.'
  end

  def then_i_see_the_updated_relationship
    expect(page).to have_content 'I sold him a moterhome.'
  end

  def when_i_choose_that_im_not_ready_to_submit_my_reference
    choose 'No, not at the moment'
  end

  def then_i_see_the_review_references_page
    expect(page).to have_current_path candidate_interface_references_review_path
  end

  def and_i_should_see_my_reference
    expect(page).to have_content 'Character reference from Jessie Pinkman'
  end

  def when_i_try_to_edit_someone_elses_reference
    non_associated_reference = create(:reference, :not_requested_yet)
    visit candidate_interface_references_edit_name_path(non_associated_reference.id)
  end

  def when_i_try_and_edit_a_reference_that_does_not_exist
    visit candidate_interface_references_edit_name_path('INVALID')
  end

  def when_i_visit_the_unsubmitted_reference_page
    visit candidate_interface_references_review_unsubmitted_path(@application.application_references.last.id)
  end

  def and_i_choose_to_submit_my_reference_now
    choose 'Yes, send a reference request now'
  end

  def then_i_see_the_candidate_name_page
    expect(page).to have_current_path candidate_interface_references_create_candidate_name_path(@application.application_references.last.id)
  end

  def and_i_have_added_my_name_to_the_application_form
    @application.update!(first_name: 'Hank', last_name: 'Schrader')
  end

  def and_i_should_be_told_my_reference_request_has_been_sent
    expect(page).to have_content 'Reference request sent to Jessie Pinkman'
  end
end
