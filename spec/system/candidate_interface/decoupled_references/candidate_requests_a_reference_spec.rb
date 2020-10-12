require 'rails_helper'

RSpec.feature 'Candidate requests a reference' do
  include CandidateHelper

  scenario 'the candidate has created a reference and chooses to send the request' do
    given_i_am_signed_in
    and_the_decoupled_references_flag_is_on
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
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_the_decoupled_references_flag_is_on
    FeatureFlag.activate('decoupled_references')
  end

  def and_i_have_added_a_reference
    @application_form = current_candidate.current_application
    @reference = create(:reference, :unsubmitted, application_form: @application_form)
  end

  def and_i_visit_the_reference_review_page
    # TODO: Navigate to the last page of the reference creation flow
    visit candidate_interface_decoupled_references_start_request_path(@reference.id)
  end

  def and_i_choose_to_request_reference_immediately
    choose 'Yes, send a reference request now'
    click_button 'Save and continue'
  end

  def then_i_am_prompted_for_my_name
    expect(page).to have_content('Tell the referee your name')
  end

  def when_i_continue_without_entering_my_name
    click_button 'Save and continue'
  end

  def then_i_see_validation_errors
    expect(page).to have_content('Enter your first name')
    expect(page).to have_content('Enter your last name')
  end

  def when_i_enter_my_name
    fill_in 'First name', with: 'Topsy'
    fill_in 'Last name', with: 'Turvey'
    click_button 'Save and continue'
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
    expect(current_email).to have_content "Give a reference for #{@application_form.reload.full_name} as soon as possible"
  end

  def when_i_have_added_a_second_reference
    @reference = create(:reference, :unsubmitted, application_form: @application_form)
  end

  def when_i_have_added_a_third_reference
    @reference = create(:reference, :unsubmitted, application_form: @application_form)
  end

  def and_i_choose_not_to_request_reference_immediately
    choose 'No, not at the moment'
    click_button 'Save and continue'
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
end
