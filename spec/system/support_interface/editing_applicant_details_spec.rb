require 'rails_helper'

RSpec.feature 'Editing application details' do
  include DfESignInHelpers

  scenario 'Support user edits applicant details', with_audited: true do
    given_i_am_a_support_user
    and_an_application_exists

    when_i_visit_the_application_page
    and_i_click_the_change_link_next_to_first_name
    and_i_fill_in_all_fields_with_blank_values
    and_i_submit_the_update_form
    then_i_should_see_relevant_blank_error_messages

    when_i_supply_new_applicant_details_with_used_email_address
    and_i_submit_the_update_form
    then_i_should_see_a_duplicate_email_error_message

    when_i_supply_new_applicant_details
    and_i_submit_the_update_form
    then_i_should_see_a_flash_message
    and_i_should_see_the_new_applicant_details

    when_i_update_the_applicant_nationality
    then_i_see_the_updated_nationality
  end

  def when_i_update_the_applicant_nationality
    click_on 'Details'
    click_link 'Change nationality'
    uncheck 'British'
    check 'Citizen of a different country'
    select 'Armenian', from: 'support-interface-application-forms-nationalities-form-other-nationality1-field'
    fill_in 'Audit log comment', with: 'Changed nationality details - zendesk ticket 1234'
    click_button t('save_and_continue')
    choose 'Not yet – I will need to apply for permission to work or study in the UK'
    fill_in 'Audit log comment', with: 'Changed nationality details - zendesk ticket 1234'
    click_button t('save_and_continue')
  end

  def then_i_see_the_updated_nationality
    within('[data-qa="personal-details"]') do
      expect(page).to have_content 'Armenian'
      expect(page).to have_content 'Has the right to work or study in the UK?'
      expect(page).to have_content 'Not yet'
    end

    click_on 'History'
    expect(page).to have_content 'Changed nationality details - zendesk ticket 1234'
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_an_application_exists
    @form = create(:completed_application_form)
  end

  def when_i_visit_the_application_page
    visit support_interface_application_form_path(@form)
  end

  def and_i_click_the_change_link_next_to_first_name
    all('.govuk-summary-list__actions')[0].click_link 'Change'
  end

  def and_i_fill_in_all_fields_with_blank_values
    fill_in 'support_interface_application_forms_edit_applicant_details_form[first_name]', with: ''
    fill_in 'support_interface_application_forms_edit_applicant_details_form[last_name]', with: ''
    fill_in 'support_interface_application_forms_edit_applicant_details_form[email_address]', with: ''
    fill_in 'Day', with: ''
    fill_in 'Month', with: ''
    fill_in 'Year', with: ''
    fill_in 'support_interface_application_forms_edit_applicant_details_form[phone_number]', with: ''
    fill_in 'support_interface_application_forms_edit_applicant_details_form[audit_comment]', with: ''
  end

  def then_i_should_see_relevant_blank_error_messages
    expect(page).to have_content 'First name cannot be blank'
    expect(page).to have_content 'Last name cannot be blank'
    expect(page).to have_content 'Email address cannot be blank'
    expect(page).to have_content 'Enter a date of birth'
    expect(page).to have_content 'Phone number can’t be blank'
    expect(page).to have_content 'You must provide an audit comment'
  end

  def and_i_supply_a_new_phone_number
    fill_in 'support_interface_application_forms_edit_applicant_details_form[phone_number]', with: '0891 50 50 50'
  end

  def when_i_supply_a_new_first_name
    fill_in 'support_interface_application_forms_edit_applicant_details_form[first_name]', with: 'Steven'
  end

  def and_i_supply_a_new_last_name
    fill_in 'support_interface_application_forms_edit_applicant_details_form[last_name]', with: 'Seagal'
  end

  def and_i_supply_a_new_email_address
    fill_in 'support_interface_application_forms_edit_applicant_details_form[email_address]', with: 'steven.seagal@example.com'
  end

  def and_i_supply_a_new_date_of_birth
    fill_in 'Day', with: '5'
    fill_in 'Month', with: '5'
    fill_in 'Year', with: '1950'
  end

  def and_i_add_a_note_for_the_audit_log
    fill_in 'support_interface_application_forms_edit_applicant_details_form[audit_comment]', with: 'https://becomingateacher.zendesk.com/12345'
  end

  def and_i_submit_the_update_form
    click_button 'Update'
  end

  def then_i_should_see_a_flash_message
    expect(page).to have_content 'Applicant details updated'
  end

  def and_i_should_see_the_new_phone_number
    expect(page).to have_content '0891 50 50 50'
  end

  def and_i_should_see_the_new_name_in_full
    expect(page).to have_content 'Steven'
    expect(page).to have_content 'Seagal'
  end

  def and_i_should_see_the_new_date_of_birth
    expect(page).to have_content '5 May 1950'
  end

  def and_i_should_see_the_new_email_address
    expect(page).to have_content 'steven.seagal@example.com'
  end

  def and_i_should_see_my_comment_in_the_audit_log
    click_on 'History'
    expect(page).to have_content 'https://becomingateacher.zendesk.com/12345'
  end

  def when_i_supply_new_applicant_details_with_used_email_address
    when_i_supply_new_applicant_details
    create :candidate, email_address: 'bob@example.com'
    fill_in 'support_interface_application_forms_edit_applicant_details_form[email_address]', with: 'bob@example.com'
  end

  def then_i_should_see_a_duplicate_email_error_message
    expect(page).to have_content 'Email address is already in use'
  end

  def when_i_supply_new_applicant_details
    when_i_supply_a_new_first_name
    and_i_supply_a_new_last_name
    and_i_supply_a_new_date_of_birth
    and_i_supply_a_new_phone_number
    and_i_supply_a_new_email_address
    and_i_add_a_note_for_the_audit_log
  end

  def and_i_should_see_the_new_applicant_details
    and_i_should_see_the_new_name_in_full
    and_i_should_see_the_new_date_of_birth
    and_i_should_see_the_new_phone_number
    and_i_should_see_the_new_email_address
    and_i_should_see_my_comment_in_the_audit_log
  end
end
