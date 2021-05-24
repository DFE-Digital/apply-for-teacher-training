require 'rails_helper'

RSpec.feature 'Candidate requests a reference' do
  include CandidateHelper

  scenario 'the candidate has created a reference and chooses to send the request' do
    given_i_am_signed_in
    and_i_have_added_a_reference
    and_i_visit_the_reference_review_page
    and_i_choose_to_request_reference_immediately
    then_i_am_prompted_for_my_name

    when_i_continue_without_entering_my_name
    then_i_see_validation_errors

    when_i_enter_my_name
    then_i_see_a_confirmation_message
    and_the_reference_is_moved_to_the_requested_state
    and_an_email_is_sent_to_the_referee

    when_i_have_added_a_second_reference
    and_i_visit_the_reference_review_page
    and_i_choose_to_request_reference_immediately
    then_i_see_a_confirmation_message
    and_the_reference_is_moved_to_the_requested_state
    and_an_email_is_sent_to_the_referee

    when_i_have_added_a_third_reference
    and_i_visit_the_reference_review_page
    and_i_choose_not_to_request_reference_immediately
    then_i_do_not_see_a_confirmation_message
    and_the_reference_is_not_moved_to_the_requested_state
    and_an_email_is_not_sent_to_the_referee

    when_i_click_the_send_reference_link
    and_i_confirm_that_i_am_ready_to_send_a_reference_request
    then_i_see_a_confirmation_message
    and_the_reference_is_moved_to_the_requested_state
    and_an_email_is_sent_to_the_referee
    when_i_navigate_back_to_a_stale_confirmation_page
    then_i_see_a_page_not_found_page

    when_i_manually_try_and_edit_my_references_type
    then_i_am_redirected_to_the_review_page

    when_i_manually_try_and_edit_my_references_name
    then_i_am_redirected_to_the_review_page

    when_i_manually_try_and_edit_my_references_email_address
    then_i_am_redirected_to_the_review_page

    when_i_manually_try_and_edit_my_references_relationship
    then_i_am_redirected_to_the_review_page

    when_i_have_added_an_incomplete_reference
    and_i_visit_the_all_references_review_page
    then_i_should_not_see_a_send_reference_link
    when_i_navigate_to_the_send_request_page
    then_i_should_see_a_not_found_message

    when_i_have_a_cancelled_reference
    and_i_visit_the_all_references_review_page
    and_i_click_the_resend_reference_link
    and_i_confirm_that_i_am_ready_to_send_a_reference_request
    then_i_see_a_confirmation_message
    and_the_reference_is_moved_to_the_requested_state
    and_an_email_is_sent_to_the_referee

    when_i_have_a_failed_reference
    and_i_visit_the_all_references_review_page
    then_i_see_the_references_review_page

    when_i_click_the_retry_request_link
    and_i_continue_with_a_blank_email_address
    then_i_see_email_address_validation_errors

    when_i_change_the_email_address
    and_i_confirm_that_i_am_ready_to_retry_a_reference_request
    then_i_see_a_confirmation_message
    and_the_reference_is_moved_to_the_requested_state
    and_the_reference_email_address_has_been_updated
    and_an_email_is_sent_to_the_referee
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_have_added_a_reference
    @application_form = current_candidate.current_application
    @reference = create(:reference, :not_requested_yet, application_form: @application_form)
  end

  def and_i_visit_the_reference_review_page
    visit candidate_interface_references_review_unsubmitted_path(@reference.id)
  end

  def and_i_choose_to_request_reference_immediately
    choose 'Yes, send a reference request now'
    click_button t('save_and_continue')
  end

  def then_i_am_prompted_for_my_name
    expect(page).to have_content('What is your name?')
  end

  def when_i_continue_without_entering_my_name
    click_button t('save_and_continue')
  end

  def then_i_see_validation_errors
    expect(page).to have_content('Enter your first name')
    expect(page).to have_content('Enter your last name')
  end

  def when_i_enter_my_name
    fill_in 'First name', with: 'Topsy'
    fill_in 'Last name', with: 'Turvey'
    click_button t('save_and_continue')
  end

  def then_i_see_a_confirmation_message
    expect(page).to have_content("Reference request sent to #{@reference.name}")
  end

  def and_the_reference_is_moved_to_the_requested_state
    expect(@reference.reload.feedback_status).to eq 'feedback_requested'
  end

  def and_an_email_is_sent_to_the_referee
    open_email(@reference.email_address)
    expect(current_email).to have_content "Dear #{@reference.name},"
    expect(current_email).to have_content "Can you give #{@application_form.reload.full_name} a reference?"
  end

  def when_i_have_added_a_second_reference
    @reference = create(:reference, :not_requested_yet, application_form: @application_form)
  end

  def when_i_have_added_a_third_reference
    @reference = create(:reference, :not_requested_yet, application_form: @application_form)
  end

  def and_i_choose_not_to_request_reference_immediately
    choose 'No, not at the moment'
    click_button t('save_and_continue')
  end

  def then_i_do_not_see_a_confirmation_message
    expect(page).not_to have_content("Reference request sent to #{@reference.name}")
  end

  def and_the_reference_is_not_moved_to_the_requested_state
    expect(@reference.reload.feedback_status).to eq 'not_requested_yet'
  end

  def and_an_email_is_not_sent_to_the_referee
    open_email(@reference.email_address)
    expect(current_email).to be_nil
  end

  def when_i_click_the_send_reference_link
    click_link 'Send request'
  end

  def and_i_confirm_that_i_am_ready_to_send_a_reference_request
    expect(page).to have_content('Are you ready to send a reference request?')
    click_button 'Yes I’m sure - send my reference request'
  end

  def when_i_navigate_back_to_a_stale_confirmation_page
    visit candidate_interface_references_new_request_path(@reference)
  end

  def then_i_see_a_page_not_found_page
    expect(page).to have_content 'Page not found'
  end

  def when_i_manually_try_and_edit_my_references_type
    visit candidate_interface_references_edit_type_path(@reference.referee_type, @reference.id)
  end

  def then_i_am_redirected_to_the_review_page
    expect(page).to have_current_path candidate_interface_references_review_path
  end

  def when_i_manually_try_and_edit_my_references_name
    visit candidate_interface_references_edit_name_path(@reference.id)
  end

  def when_i_manually_try_and_edit_my_references_email_address
    visit candidate_interface_references_edit_email_address_path(@reference.id)
  end

  def when_i_manually_try_and_edit_my_references_relationship
    visit candidate_interface_references_edit_relationship_path(@reference.id)
  end

  def when_i_have_added_an_incomplete_reference
    @reference = create(:reference, :not_requested_yet, name: nil, application_form: @application_form)
  end

  def and_i_visit_the_all_references_review_page
    visit candidate_interface_references_review_path
  end

  def then_i_should_not_see_a_send_reference_link
    expect(page).not_to have_link('Send request')
  end

  def when_i_navigate_to_the_send_request_page
    visit candidate_interface_references_new_request_path(@reference)
  end

  def then_i_should_see_a_not_found_message
    expect(page).to have_content('Page not found')
  end

  def when_i_have_a_cancelled_reference
    @reference = create(:reference, :cancelled, application_form: @application_form)
  end

  def when_i_have_a_failed_reference
    @reference = create(:reference, :email_bounced, application_form: @application_form, email_address: 'kevin@example.com')
  end

  def and_i_click_the_resend_reference_link
    click_link 'Send request again'
  end

  def then_i_see_the_references_review_page
    expect(page).to have_current_path candidate_interface_references_review_path
  end

  def when_i_click_the_retry_request_link
    click_link 'Retry request'
  end

  def and_i_continue_with_a_blank_email_address
    fill_in 'Referee’s email address', with: ''
    click_button 'Send reference request'
  end

  def then_i_see_email_address_validation_errors
    expect(page).to have_content('Enter your referee’s email address')
  end

  def when_i_change_the_email_address
    fill_in 'Referee’s email address', with: 'john@example.com'
  end

  def and_i_confirm_that_i_am_ready_to_retry_a_reference_request
    click_button 'Send reference request'
  end

  def and_the_reference_email_address_has_been_updated
    expect(@reference.reload.email_address).to eq('john@example.com')
  end
end
