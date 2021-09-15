require 'rails_helper'

RSpec.feature 'Referee does not respond in time' do
  include CandidateHelper

  scenario 'Emails are sent if a referee does not respond in time' do
    given_there_is_an_application_with_a_reference
    and_the_referee_does_not_respond_within_7_days
    then_the_referee_is_sent_a_chase_email
    and_an_email_is_sent_to_the_candidate

    when_the_candidate_does_not_respond_within_14_days
    then_an_email_is_sent_to_the_candidate_asking_for_a_new_referee

    when_the_candidate_does_not_respond_within_28_days
    then_the_candidate_is_sent_a_final_chase_email
    and_the_referee_is_sent_a_final_chase_email
  end

  def given_there_is_an_application_with_a_reference
    @reference = create(:reference, :feedback_requested, email_address: 'anne@other.com', name: 'Anne Other')
    @application = create(:application_form, first_name: 'F', last_name: 'B', application_references: [@reference])
  end

  def and_the_referee_does_not_respond_within_7_days
    Timecop.travel(7.days.from_now) do
      ChaseReferences.perform_async
      ChaseReferences.perform_async
    end
  end

  def then_the_referee_is_sent_a_chase_email
    open_email('anne@other.com')

    expect(current_emails.size).to be(1)

    expect(current_email.text).to include('We have not had your reference')
  end

  def and_an_email_is_sent_to_the_candidate
    open_email(@application.candidate.email_address)

    expect(current_emails.size).to be(1)

    expect(current_email.subject).to end_with('Anne Other has not responded yet')
  end

  def when_the_candidate_does_not_respond_within_14_days
    Timecop.travel(14.days.from_now) do
      ChaseReferences.perform_async
      ChaseReferences.perform_async
    end
  end

  def then_an_email_is_sent_to_the_candidate_asking_for_a_new_referee
    open_email(@application.candidate.email_address)

    expect(current_emails.size).to be(2)

    expect(current_email.subject).to have_content('Anne Other has not responded yet')
  end

  def when_the_candidate_does_not_respond_within_28_days
    Timecop.travel(28.days.from_now) do
      ChaseReferences.perform_async
      ChaseReferences.perform_async
    end
  end

  def then_the_candidate_is_sent_a_final_chase_email
    open_email(@application.candidate.email_address)

    expect(current_emails.size).to be(3)

    expect(current_email.subject).to have_content('Anne Other has not responded yet')
  end

  def and_the_referee_is_sent_a_final_chase_email
    open_email('anne@other.com')

    expect(current_emails.size).to be(2)

    expect(current_email.subject).to have_content("Can you give #{@application.full_name} a reference for their teacher training application?")
  end
end
