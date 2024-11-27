require 'rails_helper'

RSpec.describe 'Refusing to give a reference' do
  include CandidateHelper

  before do
    TestSuiteTimeMachine.travel_permanently_to(CycleTimetable.apply_deadline(2021))
  end

  scenario 'Referee refuses to give a reference' do
    given_i_am_a_referee_of_an_application
    and_i_received_the_initial_reference_request_email
    then_i_receive_an_email_with_a_reference_request

    when_i_click_the_reference_link
    then_i_see_the_give_a_reference_page
    when_i_select_no_to_giving_a_reference
    and_i_see_the_confirmation_page
    and_i_confirm_that_i_wont_give_a_reference
    and_a_slack_notification_is_sent
    then_an_email_is_sent_to_the_candidate
    then_i_see_the_thank_you_page
  end

  def given_i_am_a_referee_of_an_application
    @reference = create(:reference, :feedback_requested, email_address: 'terri@example.com', name: 'Terri Tudor')
    @application = create(:completed_application_form, application_references: [@reference])
    @application_choice = create(:application_choice, :accepted, application_form: @application)
  end

  def and_i_received_the_initial_reference_request_email
    RefereeMailer.reference_request_email(@reference).deliver_now
  end

  def then_i_receive_an_email_with_a_reference_request
    open_email('terri@example.com')
  end

  def when_i_click_the_reference_link
    current_email.click_link_or_button(give_feedback_url)
  end

  def then_i_see_the_give_a_reference_page
    expect(page).to have_content("Give a reference for #{@application.full_name}")
    expect(page).to have_content(@application_choice.provider.name.to_s)
  end

  def when_i_select_no_to_giving_a_reference
    choose 'No, I’m unable to give a reference'
    click_link_or_button t('save_and_continue')
  end

  def and_i_see_the_confirmation_page
    expect(page).to have_content("Are you sure you are unable to give #{@application.full_name} a reference?")
  end

  def and_i_confirm_that_i_wont_give_a_reference
    click_link_or_button 'Yes, I am unable to give a reference'
  end

  def and_a_slack_notification_is_sent
    expect_slack_message_with_text ":sadparrot: A referee declined to give feedback for #{@application.first_name}’s application"
  end

  def then_an_email_is_sent_to_the_candidate
    open_email(@application.candidate.email_address)

    expect(current_email.subject).to have_content('Terri Tudor is unable to give you a reference')
  end

  def then_i_see_the_thank_you_page
    expect(page).to have_content('Thank you')
  end

private

  def give_feedback_url
    matches = current_email.body.match(/(http:\/\/localhost:3000\/reference\?token=[\w-]{20})/)
    matches&.captures&.first
  end
end
