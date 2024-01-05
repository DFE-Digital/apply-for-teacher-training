require 'rails_helper'

RSpec.feature 'Deleting references' do
  include DfESignInHelpers
  include CandidateHelper

  it 'Support user deletes a reference', :with_audited do
    given_i_am_a_support_user
    and_an_application_exists_with_reference

    when_i_visit_the_application_page
    and_i_click_the_delete_link_next_to_reference
    then_i_should_see_a_confirmation_form

    when_i_submit_the_confirmation_form
    then_i_should_see_blank_zendesk_url_error_message

    when_i_complete_the_confirmation_form
    when_i_submit_the_confirmation_form
    then_i_should_see_a_flash_message
    and_i_should_not_see_the_deleted_reference_details
    and_i_should_see_my_zendesk_ticket_in_the_audit_log
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_an_application_exists_with_reference
    @form = create(:application_form, :with_completed_references)
    @reference = create(:reference, :feedback_requested, name: 'Dumbledore', email_address: 'a.dumbledore@hogwarts.ac.uk', relationship: 'Headmaster', application_form: @form)
  end

  def when_i_visit_the_application_page
    visit support_interface_application_form_path(@form)
  end

  def and_i_click_the_delete_link_next_to_reference
    within_summary_card('Dumbledore') do
      click_link 'Delete'
    end
  end

  def then_i_should_see_a_confirmation_form
    expect(page).to have_content('Are you sure you want to delete the reference from Dumbledore?')
  end

  def when_i_submit_the_confirmation_form
    click_button 'Permanently delete reference'
  end

  def then_i_should_see_blank_zendesk_url_error_message
    expect(page).to have_content('Enter a Zendesk ticket URL')
  end

  def when_i_complete_the_confirmation_form
    fill_in 'Zendesk ticket URL', with: 'https://becomingateacher.zendesk.com/agent/tickets/12345'
    check 'I have read the guidance'
  end

  def then_i_should_see_a_flash_message
    expect(page).to have_content 'Reference deleted'
  end

  def and_i_should_not_see_the_deleted_reference_details
    expect(page).to have_no_content 'Dumbledore'
  end

  def and_i_should_see_my_zendesk_ticket_in_the_audit_log
    click_link 'History'
    expect(page).to have_content 'Destroy Application Reference'
    expect(page).to have_content 'https://becomingateacher.zendesk.com/agent/tickets/12345'
  end
end
