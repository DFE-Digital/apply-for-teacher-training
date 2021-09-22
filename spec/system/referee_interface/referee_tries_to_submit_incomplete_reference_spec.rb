require 'rails_helper'

RSpec.feature 'Stop submission of incomplete references', with_audited: true do
  include CandidateHelper

  scenario 'Referee tries to submit incomplete reference' do
    given_i_am_a_referee_of_an_application
    and_i_received_the_initial_reference_request_email
    when_i_click_on_the_link_within_the_initial_email
    and_i_confirm_my_relationship_with_the_candidate
    and_i_manually_skip_ahead_to_the_review_page
    then_i_cannot_submit_the_reference
  end

  def given_i_am_a_referee_of_an_application
    @reference = create(:reference, :feedback_requested)
    @application = create(
      :completed_application_form,
      references_count: 0,
      application_references: [@reference],
    )
  end

  def and_i_received_the_initial_reference_request_email
    RefereeMailer.reference_request_email(@reference).deliver_now
  end

  def when_i_click_on_the_link_within_the_initial_email
    open_email(@reference.email_address)

    click_sign_in_link(current_emails.first)
  end

  def and_i_confirm_my_relationship_with_the_candidate
    expect(page).to have_content("Confirm how you know #{@application.full_name}")
    choose 'Yes'
    click_button t('save_and_continue')
  end

  def and_i_manually_skip_ahead_to_the_review_page
    visit referee_interface_reference_review_path(token: @token)
  end

  def then_i_cannot_submit_the_reference
    click_button 'Submit reference'
    expect(page).to have_content 'Cannot submit a reference without answers to all questions'
    expect(ApplicationReference.feedback_provided).to be_empty
  end
end
