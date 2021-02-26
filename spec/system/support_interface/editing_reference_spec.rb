require 'rails_helper'

RSpec.feature 'Editing reference' do
  include DfESignInHelpers

  scenario 'Support user edits reference', with_audited: true do
    given_i_am_a_support_user
    and_an_application_exists

    when_i_visit_the_application_page
    and_i_click_the_change_link_next_to_referee_name
    then_i_should_see_a_prepopulated_details_form

    when_i_submit_the_update_form
    then_i_should_see_blank_audit_comment_error_message

    when_i_complete_the_details_form
    and_i_submit_the_update_form
    then_i_should_see_a_flash_message
    and_i_should_see_the_new_details
    and_i_should_see_my_details_comment_in_the_audit_log

    when_i_visit_the_application_page
    and_i_click_the_change_link_next_to_feedback
    then_i_should_see_the_feedback_form

    when_i_submit_the_update_form
    then_i_should_see_relevant_blank_error_messages

    when_i_complete_the_feedback_form
    and_i_submit_the_update_form
    then_i_should_see_a_flash_message
    and_i_should_see_the_new_feedback
    and_i_should_see_my_feedback_comment_in_the_audit_log
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_an_application_exists
    @form = create(:application_form, :with_completed_references)
    create(:reference, :feedback_requested, name: 'Dumbledore', email_address: 'a.dumbledore@hogwarts.ac.uk', relationship: 'Headmaster', application_form: @form)
  end

  def when_i_visit_the_application_page
    visit support_interface_application_form_path(@form)
  end

  def and_i_click_the_change_link_next_to_referee_name
    all('.govuk-summary-list__actions')[11].click_link 'Change'
  end

  def then_i_should_see_a_prepopulated_details_form
    expect(page).to have_content('Edit reference details')
    expect(page).to have_selector("input[value='Dumbledore']")
    expect(page).to have_selector("input[value='a.dumbledore@hogwarts.ac.uk']")
    expect(page).to have_selector("input[value='Headmaster']")
  end

  def when_i_submit_the_update_form
    click_button 'Update'
  end
  alias_method :and_i_submit_the_update_form, :when_i_submit_the_update_form

  def then_i_should_see_blank_audit_comment_error_message
    expect(page).to have_content t('activemodel.errors.models.support_interface/application_forms/edit_reference_details_form.attributes.audit_comment.blank')
  end

  def when_i_complete_the_details_form
    fill_in 'support_interface_application_forms_edit_reference_details_form[name]', with: 'McGonagall'
    fill_in 'support_interface_application_forms_edit_reference_details_form[email_address]', with: 'm.mcgonagall@hogwarts.ac.uk'
    fill_in 'support_interface_application_forms_edit_reference_details_form[relationship]', with: 'Head of House'
    fill_in 'support_interface_application_forms_edit_reference_details_form[audit_comment]', with: 'Updated as part of Zen Desk ticket #12345'
  end

  def then_i_should_see_a_flash_message
    expect(page).to have_content 'Reference updated'
  end

  def and_i_should_see_the_new_details
    expect(page).to have_content 'McGonagall'
    expect(page).to have_content 'm.mcgonagall@hogwarts.ac.uk'
    expect(page).to have_content 'Head of House'
  end

  def and_i_should_see_my_details_comment_in_the_audit_log
    click_on 'History'
    expect(page).to have_content 'Updated as part of Zen Desk ticket #12345'
  end

  def and_i_click_the_change_link_next_to_feedback
    all('.govuk-summary-list__actions')[14].click_link 'Change'
  end

  def then_i_should_see_the_feedback_form
    expect(page).to have_content('Edit reference feedback')
  end

  def then_i_should_see_relevant_blank_error_messages
    expect(page).to have_content t('activemodel.errors.models.support_interface/application_forms/edit_reference_feedback_form.attributes.feedback.blank')
    expect(page).to have_content t('activemodel.errors.models.support_interface/application_forms/edit_reference_feedback_form.attributes.audit_comment.blank')
    expect(page).to have_content t('activemodel.errors.models.support_interface/application_forms/edit_reference_feedback_form.attributes.send_emails.blank')
  end

  def when_i_complete_the_feedback_form
    fill_in 'support_interface_application_forms_edit_reference_feedback_form[feedback]', with: 'Harry is a good egg'
    fill_in 'support_interface_application_forms_edit_reference_feedback_form[audit_comment]', with: 'Updated as part of Zen Desk ticket #12346'
    choose 'Yes'
  end

  def and_i_should_see_the_new_feedback
    expect(page).to have_content 'Harry is a good egg'
  end

  def and_i_should_see_my_feedback_comment_in_the_audit_log
    click_on 'History'
    expect(page).to have_content 'Updated as part of Zen Desk ticket #12346'
  end
end
