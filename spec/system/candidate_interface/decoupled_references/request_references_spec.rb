require 'rails_helper'

RSpec.feature 'Review references' do
  include CandidateHelper

  scenario 'the candidate has created a reference and chooses to send the request' do
    given_i_am_signed_in
    and_the_decoupled_references_flag_is_on
    and_i_have_added_a_reference
    and_i_choose_to_request_reference_immediately
    then_i_am_prompted_for_my_name

    when_i_enter_my_name
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
    application_form = current_candidate.current_application
    @reference = create(:reference, :unsubmitted, application_form: application_form)
  end

  def and_i_choose_to_request_reference_immediately
    # TODO: Navigate to the last page of the reference creation flow
    # choose 'Yes, send a reference request now'
    # click_button 'Save and continue'
    visit candidate_interface_decoupled_references_new_request_path(@reference.id)
  end

  def then_i_am_prompted_for_my_name
    expect(page).to have_content('Tell the referee your name')
  end

  def when_i_enter_my_name
    fill_in 'First name', with: 'Topsy'
    fill_in 'Last name', with: 'Turvey'
    click_button 'Save and continue'
  end

  def then_i_see_a_confirmation_message
    expect(page).to have_content("Reference request sent to #{reference.name}")
  end

  def and_the_reference_is_moved_to_the_requested_state
    expect(@reference.reload.feedback_status).to eq 'feedback_requested'
  end

  def and_an_email_is_sent_to_the_referee
    open_email(@reference.email_address)
    expect(current_email).to have_content "Give #{@application_form.full_name} a reference for their teacher training application as soon as possible"
  end

  # TODO: Request a second reference
end
