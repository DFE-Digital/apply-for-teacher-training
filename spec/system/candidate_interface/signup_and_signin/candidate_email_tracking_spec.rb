require 'rails_helper'

RSpec.describe 'Candidate email click tracking' do
  it 'Candidate clicks a sign in link in a nudge email' do
    given_i_have_been_sent_a_nudge_email
    then_an_email_is_logged

    when_i_open_the_nudge_email_and_click_on_the_link

    then_an_email_click_is_logged
  end

private

  def given_i_have_been_sent_a_nudge_email
    application_form = current_candidate.current_application
    CandidateMailer.nudge_unsubmitted(application_form).deliver_now
  end

  def then_an_email_is_logged
    @email = Email.last
    expect(@email).to be_present
    expect(@email.email_clicks).to be_empty
  end

  def when_i_open_the_nudge_email_and_click_on_the_link
    email = open_email(current_candidate.email_address)
    application_choice_link = email.body.match(/#{candidate_interface_application_choices_path}\?utm_source=test-[a-zA-Z0-9]+/)[0]
    expect(application_choice_link).to be_present
    visit application_choice_link
  end

  def then_an_email_click_is_logged
    expect(@email.reload.email_clicks.count).to eq(1)
  end
end
