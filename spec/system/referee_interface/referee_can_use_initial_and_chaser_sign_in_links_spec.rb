require 'rails_helper'

RSpec.feature 'Referee can use sign in link in the initial and chaser email' do
  scenario 'Referee clicks sign in links on the initial and chaser reference request emails' do
    given_the_confirm_relationship_and_safeguarding_feature_flag_is_active
    and_i_am_a_referee_of_an_submitted_application
    and_i_received_the_initial_reference_request_email
    when_i_click_on_the_link_within_the_initial_email
    then_i_am_asked_to_confirm_my_relationship_with_the_candidate

    given_i_received_the_chaser_reference_request_email
    when_i_click_on_the_link_within_the_chaser_email
    then_i_am_asked_to_confirm_my_relationship_with_the_candidate

    when_i_click_on_the_link_within_the_initial_email
    then_i_am_asked_to_confirm_my_relationship_with_the_candidate
  end

  def given_the_confirm_relationship_and_safeguarding_feature_flag_is_active
    FeatureFlag.activate('referee_confirm_relationship_and_safeguarding')
  end

  def and_i_am_a_referee_of_an_submitted_application
    @reference = create(:reference, :requested)
    @application = create(:completed_application_form, application_references: [@reference])
  end

  def and_i_received_the_initial_reference_request_email
    RefereeMailer.reference_request_email(@application, @reference).deliver_now
  end

  def when_i_click_on_the_link_within_the_initial_email
    open_email(@reference.email_address)

    click_sign_in_link(current_emails.first)
  end

  def then_i_am_asked_to_confirm_my_relationship_with_the_candidate
    expect(page).to have_content("Confirm how you know #{@application.full_name}")
  end

  def given_i_received_the_chaser_reference_request_email
    RefereeMailer.reference_request_chaser_email(@application, @reference).deliver_now
  end

  def when_i_click_on_the_link_within_the_chaser_email
    open_email(@reference.email_address)

    click_sign_in_link(current_emails.second)
  end

  def click_sign_in_link(email)
    matches = email.body.match(/(http:\/\/localhost:3000\/reference\?token=[\w-]{20})/)
    reference_feedback_url = matches.captures.first unless matches.nil?

    email.click_link(reference_feedback_url)
  end
end
