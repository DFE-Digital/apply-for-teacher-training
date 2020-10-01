require 'rails_helper'

RSpec.feature 'Decoupled references' do
  include CandidateHelper

  scenario 'candidate adds a new reference' do
    given_i_am_signed_in
    and_the_decoupled_references_flag_is_on

    when_i_visit_the_site
    then_i_should_see_the_decoupled_references_section

    when_i_click_add_you_references
    then_i_see_the_start_page

    when_i_click_continue
    then_i_see_the_type_page

    when_i_select_academic
    and_i_click_save_and_continue
    then_i_should_see_the_referee_name_page

    when_i_click_save_and_continue_without_providing_a_name
    then_i_should_be_told_to_provide_a_name

    when_i_fill_in_my_references_name
    and_i_click_save_and_continue

    when_i_click_save_and_continue_without_providing_an_emailing
    then_i_should_be_told_to_provide_an_email_address

    when_i_provide_an_email_address_with_an_invalid_format
    and_i_click_save_and_continue
    then_i_am_told_my_email_address_needs_a_valid_format

    when_i_provide_a_valid_email_address
    and_i_click_save_and_continue
    then_i_see_the_description_page

    when_i_click_save_and_continue_without_providing_a_description
    then_i_should_be_told_to_provide_a_description

    when_i_fill_in_my_references_description
    and_i_click_save_and_continue
    then_i_should_see_the_review_unsubmitted_page
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
    @application = @candidate.current_application
  end

  def and_the_decoupled_references_flag_is_on
    FeatureFlag.activate('decoupled_references')
  end

  def when_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def then_i_should_see_the_decoupled_references_section
    expect(page).to have_content 'It takes 8 days to get a reference on average.'
  end

  def when_i_click_add_you_references
    click_link 'Add your references'
  end

  def then_i_see_the_start_page
    expect(page).to have_current_path candidate_interface_decoupled_references_start_path
  end

  def when_i_click_continue
    click_link 'Continue'
  end

  def then_i_see_the_type_page
    expect(page).to have_current_path candidate_interface_decoupled_references_new_type_path
  end

  def when_i_select_academic
    choose 'Academic'
  end

  def and_i_click_save_and_continue
    click_button 'Save and continue'
  end

  def then_i_should_see_the_referee_name_page
    expect(page).to have_current_path candidate_interface_decoupled_references_new_name_path(@application.application_references.last.id)
  end

  def when_i_click_save_and_continue_without_providing_a_name
    and_i_click_save_and_continue
  end

  def then_i_should_be_told_to_provide_a_name
    expect(page).to have_content 'Enter your referees name'
  end

  def when_i_fill_in_my_references_name
    fill_in 'candidate-interface-reference-referee-name-form-name-field-error', with: 'Walter White'
  end

  def then_i_see_the_referee_email_page
    expect(page).to have_current_path candidate_interface_decoupled_references_new_email_address_path(@application.application_references.last.id)
  end

  def when_i_click_save_and_continue_without_providing_an_emailing
    and_i_click_save_and_continue
  end

  def then_i_should_be_told_to_provide_an_email_address
    expect(page).to have_content 'Enter your referees email address'
  end

  def when_i_provide_an_email_address_with_an_invalid_format
    fill_in 'candidate-interface-reference-referee-email-address-form-email-address-field-error', with: 'invalid.email.address'
  end

  def then_i_am_told_my_email_address_needs_a_valid_format
    expect(page).to have_content 'Enter an email address in the correct format, like name@example.com'
  end

  def when_i_provide_a_valid_email_address
    fill_in 'candidate-interface-reference-referee-email-address-form-email-address-field-error', with: 'iamtheone@whoknocks.com'
  end

  def then_i_see_the_description_page
    expect(page).to have_current_path candidate_interface_decoupled_references_new_relationship_path(@application.application_references.last.id)
  end

  def when_i_click_save_and_continue_without_providing_a_description
    and_i_click_save_and_continue
  end

  def then_i_should_be_told_to_provide_a_description
    expect(page).to have_content 'Enter how you know this referee.'
  end

  def when_i_fill_in_my_references_description
    fill_in 'candidate-interface-reference-referee-relationship-form-relationship-field-error', with: 'Through nefarious behaviour.'
  end

  def then_i_should_see_the_review_unsubmitted_page
    expect(page).to have_current_path candidate_interface_decoupled_references_review_unsubmitted_path(@application.application_references.last.id)
  end
end
