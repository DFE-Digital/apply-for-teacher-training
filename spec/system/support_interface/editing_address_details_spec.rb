require 'rails_helper'

RSpec.feature 'Editing reference' do
  include DfESignInHelpers

  scenario 'Support user edits reference', with_audited: true do
    given_i_am_a_support_user
    and_an_application_exists

    when_i_visit_the_application_page
    and_i_click_the_change_link_next_to_address
    then_i_should_see_the_address_type_page

    when_i_select_uk
    then_i_should_see_the_uk_address_details_form

    when_i_submit_the_update_form
    then_i_should_see_blank_audit_comment_error_message

    when_i_complete_the_details_form
    and_i_submit_the_update_form
    then_i_should_see_a_flash_message
    and_i_should_see_the_new_details
    and_i_should_see_my_details_comment_in_the_audit_log

    when_i_visit_the_application_page
    and_i_click_the_change_link_next_to_address
    and_i_select_outside_the_uk
    then_i_should_see_the_international_address_details_form

    when_i_submit_the_update_form
    then_i_should_see_blank_error_messages

    when_i_fill_in_an_international_address
    and_i_submit_the_update_form
    then_i_should_see_a_flash_message
    and_i_should_see_the_new_international_address_details
    and_i_should_see_my_international_address_details_comment_in_the_audit_log
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_an_application_exists
    @form = create(:completed_application_form, :with_completed_references)
    create(:reference, :feedback_requested, name: 'Dumbledore', email_address: 'a.dumbledore@hogwarts.ac.uk', relationship: 'Headmaster', application_form: @form)
  end

  def when_i_visit_the_application_page
    visit support_interface_application_form_path(@form)
  end

  def and_i_click_the_change_link_next_to_address
    all('.govuk-summary-list__actions')[5].click_link 'Change'
  end

  def then_i_should_see_the_address_type_page
    expect(page).to have_content('Where does the candidate live?')
  end

  def when_i_select_uk
    choose 'In the UK'
    click_button 'Save and continue'
  end

  def then_i_should_see_the_uk_address_details_form
    expect(page).to have_content('What is the candidate’s address?')
    expect(page).to have_content('Building and street')
  end

  def when_i_submit_the_update_form
    click_button 'Save and continue'
  end
  alias_method :and_i_submit_the_update_form, :when_i_submit_the_update_form

  def then_i_should_see_blank_audit_comment_error_message
    expect(page).to have_content t('activemodel.errors.models.support_interface/application_forms/edit_address_details_form.attributes.audit_comment.blank')
  end

  def when_i_complete_the_details_form
    find(:css, "[autocomplete='address-line1']").fill_in with: '42 Much Wow Street'
    fill_in t('application_form.contact_information.address_line3.label'), with: 'London'
    fill_in t('application_form.contact_information.postcode.label'), with: 'SW1P 3BT'
    fill_in 'support_interface_application_forms_edit_address_details_form[audit_comment]', with: 'Updated as part of Zen Desk ticket #12345'
  end

  def then_i_should_see_a_flash_message
    expect(page).to have_content 'Address details updated'
  end

  def and_i_should_see_the_new_details
    expect(page).to have_content '42 Much Wow Street'
    expect(page).to have_content 'London'
    expect(page).to have_content 'SW1P 3BT'
  end

  def and_i_should_see_my_details_comment_in_the_audit_log
    click_on 'History'
    expect(page).to have_content 'Updated as part of Zen Desk ticket #12345'
  end

  def and_i_select_outside_the_uk
    choose 'Outside the UK'
    select('France', from: t('application_form.contact_information.country.label'))
    click_button 'Save and continue'
  end

  def then_i_should_see_the_international_address_details_form
    expect(page).to have_content('International address')
  end

  def then_i_should_see_blank_error_messages
    expect(page).to have_content t('activemodel.errors.models.support_interface/application_forms/edit_address_details_form.attributes.international_address.blank')
    expect(page).to have_content t('activemodel.errors.models.support_interface/application_forms/edit_address_details_form.attributes.audit_comment.blank')
  end

  def when_i_fill_in_an_international_address
    fill_in t('support_interface.edit_address_details_form.international_address.label'), with: 'Rue de Rivoli, 75001 Paris'
    fill_in 'support_interface_application_forms_edit_address_details_form[audit_comment]', with: 'Updated as part of Zen Desk ticket #56789'
  end

  def and_i_should_see_the_new_international_address_details
    expect(page).to have_content 'Rue de Rivoli, 75001 Paris'
    expect(page).to have_content 'France'
  end

  def and_i_should_see_my_international_address_details_comment_in_the_audit_log
    click_on 'History'
    expect(page).to have_content 'Updated as part of Zen Desk ticket #56789'
  end
end
