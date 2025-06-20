require 'rails_helper'

RSpec.describe 'References' do
  include CandidateHelper

  it 'the candidate can continue to request and add references on an unsubmitted application' do
    given_i_am_signed_in
    and_i_have_provided_my_personal_details
    and_i_have_three_reference_requests_pending

    when_i_receive_two_references
    then_i_still_have_a_reference_request_outstanding
    and_i_can_add_more_reference_requests
    and_i_can_receive_more_references
  end

  def given_i_am_signed_in
    given_i_am_signed_in_with_one_login
    @application = @current_candidate.current_application
  end

  def and_i_have_provided_my_personal_details
    @current_candidate.current_application.update!(first_name: 'Mr', last_name: 'Bot')
  end

  def and_i_have_three_reference_requests_pending
    create_list(:reference, 3, :feedback_requested, application_form: @application)
  end

  def when_i_receive_two_references
    receive_references
  end

  def then_i_still_have_a_reference_request_outstanding
    visit candidate_interface_references_review_path
    expect(page).to have_content('has already given a reference', count: 2)
  end

  def and_i_can_add_more_reference_requests
    visit candidate_interface_references_start_path
    click_link_or_button 'Add another reference'
    choose 'Academic'
    click_link_or_button t('continue')
    candidate_fills_in_referee(name: 'Anne Other')

    expect(page).to have_content('Change reference type for Anne Other')
  end

  def and_i_can_receive_more_references
    reference = @application.application_references.creation_order.last
    SubmitReference.new(reference:).save!
    expect(reference.reload.feedback_status).to eq('feedback_provided')
  end
end
