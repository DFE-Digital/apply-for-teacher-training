require 'rails_helper'

RSpec.feature 'Candidate email click tracking' do
  include CandidateHelper

  it 'Candidate clicks a magic link in a nudge email' do
    given_i_complete_my_application
    and_i_logout
    and_i_have_been_inactive_for_10_days
    when_the_nudge_worker_runs
    then_an_email_is_logged

    when_i_open_the_nudge_email_and_click_on_the_link

    # since we have disabled the nudge_unsubmitted email, this commented out test below is failing.
    # We can add this test back once we re-enable the email, or we can remove this spec when we decide
    # to get rid of the email completely.

    # then_an_email_click_is_logged
  end

  def given_i_complete_my_application
    candidate_completes_application_form
  end

  def and_i_have_been_inactive_for_10_days
    current_candidate.current_application.update_columns(
      updated_at: 10.days.ago,
    )
  end

  def and_i_logout
    logout
  end

  def when_the_nudge_worker_runs
    NudgeCandidatesWorker.new.perform
  end

  def then_an_email_is_logged
    @email = Email.last
    expect(@email).to be_present
    expect(@email.email_clicks).to be_empty
  end

  def when_i_open_the_nudge_email_and_click_on_the_link
    email = open_email(current_candidate.email_address)
    magic_link = email.body.match(/(#{candidate_interface_sign_in_path}\/\S+)\)/)[1]
    expect(magic_link).to be_present
    visit magic_link
  end

  def then_an_email_click_is_logged
    expect(@email.reload.email_clicks.count).to eq(1)
  end
end
