require 'rails_helper'

RSpec.feature 'Referee does not respond within 5 days', sidekiq: true do
  include CandidateHelper

  scenario 'A chase email is sent if a referee does not respond within 5 days' do
    FeatureFlag.activate('training_with_a_disability')
    FeatureFlag.activate('automated_referee_chaser')

    given_a_candidate_completed_an_application
    when_the_candidate_submits_the_application
    and_the_referee_does_not_respond_within_5_days
    then_the_referee_is_sent_a_chase_email
    and_an_email_is_sent_to_the_candidate
  end

  def given_a_candidate_completed_an_application
    candidate_completes_application_form
  end

  def when_the_candidate_submits_the_application
    candidate_submits_application
    @application.application_references.first.update!(feedback_status: :feedback_refused)
  end

  def and_the_referee_does_not_respond_within_5_days
    Timecop.travel(Time.zone.now + 5.days + 1.second) do
      SendChaseEmailToRefereesWorker.perform_async
    end
  end

  def then_the_referee_is_sent_a_chase_email
    open_email('anne@other.com')

    expect(current_email.text).to include('We haven’t had your reference')
  end

  def and_an_email_is_sent_to_the_candidate
    open_email(@application.candidate.email_address)

    expect(current_email.subject).to have_content(t('candidate_reference.subject.chaser', referee_name: 'Anne Other'))
  end
end
