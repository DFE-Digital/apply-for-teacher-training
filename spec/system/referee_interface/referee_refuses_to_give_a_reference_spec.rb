require 'rails_helper'

RSpec.feature 'Refusing to give a reference' do
  include CandidateHelper

  before { FeatureFlag.activate(:decoupled_references) }

  scenario 'Referee refuses to give a reference' do
    given_i_am_a_referee_of_an_application
    and_i_received_the_initial_reference_request_email
    then_i_receive_an_email_with_a_reference_request

    when_i_click_the_refuse_reference_link_in_the_email
    and_i_say_that_i_do_actually_want_to_give_a_reference
    then_i_see_the_reference_comment_page

    when_i_click_the_refuse_reference_link_in_the_email
    and_i_confirm_that_i_wont_give_a_reference
    and_a_slack_notification_is_sent
    then_an_email_is_sent_to_the_candidate
    and_i_should_see_the_thank_you_page
  end

  def given_i_am_a_referee_of_an_application
    @reference = create(:reference, :requested, email_address: 'terri@example.com', name: 'Terri Tudor')
    @application = create(:completed_application_form, application_references: [@reference])
  end

  def and_i_received_the_initial_reference_request_email
    RefereeMailer.reference_request_email(@reference).deliver_now
  end

  def then_i_receive_an_email_with_a_reference_request
    open_email('terri@example.com')
  end

  def when_i_click_the_refuse_reference_link_in_the_email
    current_email.click_link(refuse_feedback_url)
  end

  def and_i_say_that_i_do_actually_want_to_give_a_reference
    click_link 'Cancel'
  end

  def then_i_see_the_reference_comment_page
    expect(page).to have_content("Your reference for #{@application.full_name}")
  end

  def and_a_slack_notification_is_sent
    expect_slack_message_with_text ":sadparrot: A referee declined to give feedback for #{@application.first_name}’s application"
  end

  def and_i_confirm_that_i_wont_give_a_reference
    click_button 'Yes - I’m sure'
  end

  def then_an_email_is_sent_to_the_candidate
    open_email(@application.candidate.email_address)

    expect(current_email.subject).to have_content('Terri Tudor has declined your reference request')
  end

  def and_i_should_see_the_thank_you_page
    expect(page).to have_content('Thank you')
  end

private

  def refuse_feedback_url
    matches = current_email.body.match(/(http:\/\/localhost:3000\/reference\/refuse-feedback\?token=[\w-]{20})/)
    matches.captures.first unless matches.nil?
  end
end
