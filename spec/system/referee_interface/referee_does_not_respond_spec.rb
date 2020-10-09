require 'rails_helper'

RSpec.feature 'Referee does not respond in time' do
  include CandidateHelper

  before { FeatureFlag.deactivate(:decoupled_references) }

  scenario 'Emails are sent if a referee does not respond in time' do
    given_a_candidate_completed_an_application
    when_the_candidate_submits_the_application
    and_the_referee_does_not_respond_within_7_days
    then_the_referee_is_sent_a_chase_email
    and_an_email_is_sent_to_the_candidate

    when_the_candidate_does_not_respond_within_14_days
    then_an_email_is_sent_to_the_candidate_asking_for_a_new_referee

    when_the_candidate_does_not_respond_within_28_days
    then_the_candidate_is_sent_a_chase_email
    and_the_referee_is_sent_a_chase_email
  end

  def given_a_candidate_completed_an_application
    candidate_completes_application_form
  end

  def when_the_candidate_submits_the_application
    candidate_submits_application
    @application.application_references.first.update!(feedback_status: :feedback_refused)
  end

  def and_the_referee_does_not_respond_within_7_days
    Timecop.travel(7.days.from_now) do
      SendReferenceChaseEmailToBothPartiesWorker.perform_async
    end
  end

  def then_the_referee_is_sent_a_chase_email
    open_email('anne@other.com')

    expect(current_email.text).to include('We have not had your reference')
  end

  def and_an_email_is_sent_to_the_candidate
    open_email(@application.candidate.email_address)

    expect(current_email.subject).to end_with('Anne Other has not responded yet')
  end

  def when_the_candidate_does_not_respond_within_14_days
    Timecop.travel(14.days.from_now) do
      AskCandidatesForNewRefereesWorker.perform_async
    end
  end

  def then_an_email_is_sent_to_the_candidate_asking_for_a_new_referee
    open_email(@application.candidate.email_address)

    expect(current_email.subject).to have_content('Anne Other has not responded yet')
  end

  def when_the_candidate_does_not_respond_within_28_days
    Timecop.travel(28.days.from_now) do
      SendAdditionalReferenceChaseEmailToBothPartiesWorker.perform_async
    end
  end

  def then_the_candidate_is_sent_a_chase_email
    open_email(@application.candidate.email_address)

    expect(current_email.subject).to have_content('Anne Other has not responded yet')
  end

  def and_the_referee_is_sent_a_chase_email
    open_email(@application.application_references.second.email_address)

    expect(current_email.subject).to have_content("Will you not give #{@application.full_name} a reference?")
  end
end
