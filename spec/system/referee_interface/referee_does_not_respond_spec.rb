require 'rails_helper'

RSpec.feature 'Referee does not respond in time' do
  include CandidateHelper

  it 'Emails are sent if a referee does not respond in time' do
    given_the_new_reference_flow_feature_flag_is_on

    given_there_is_an_application_with_a_reference
    and_the_referee_does_not_respond_within_7_days
    then_the_referee_is_sent_a_chase_email

    and_the_referee_does_not_respond_within_9_days
    and_an_email_is_sent_to_the_candidate

    when_the_referee_does_not_respond_within_14_days
    then_the_referee_is_sent_another_chaser_email

    when_the_candidate_does_not_respond_within_16_days
    then_an_email_is_sent_to_the_candidate_asking_for_a_new_referee

    when_the_referee_does_not_respond_within_28_days
    and_the_referee_is_sent_a_final_chase_email

    when_the_candidate_does_not_respond_within_30_days
    then_the_candidate_is_sent_a_final_chase_email

    when_200_days_have_passed
    no_new_emails_have_been_sent
  end

  def given_the_new_reference_flow_feature_flag_is_on
    FeatureFlag.activate(:new_references_flow)
  end

  def given_there_is_an_application_with_a_reference
    @application = create(:application_form, first_name: 'F', last_name: 'B', recruitment_cycle_year: RecruitmentCycle.current_year)
    @reference = create(:reference, :feedback_requested, email_address: 'anne@other.com', name: 'Anne Other', application_form: @application)
    create(:application_choice, :with_accepted_offer, application_form: @application)
  end

  def and_the_referee_does_not_respond_within_7_days
    Timecop.travel(7.days.from_now) do
      ChaseReferences.perform_async
      ChaseReferences.perform_async
    end
  end

  def and_the_referee_does_not_respond_within_9_days
    Timecop.travel(9.days.from_now) do
      2.times { ChaseReferences.perform_async }
    end
  end

  def when_the_referee_does_not_respond_within_14_days
    Timecop.travel(14.days.from_now) do
      ChaseReferences.perform_async
      ChaseReferences.perform_async
    end
  end

  def then_the_referee_is_sent_a_chase_email
    open_email('anne@other.com')

    expect(current_emails.size).to be(1)

    expect(current_email.text).to include('Use this link to give the reference or to say you cannot give one')
  end

  def then_the_referee_is_sent_another_chaser_email
    open_email('anne@other.com')

    expect(current_emails.size).to be(2)

    expect(current_email.text).to include('Use this link to give the reference or to say you cannot give one')
  end

  def and_an_email_is_sent_to_the_candidate
    open_email(@application.candidate.email_address)

    expect(current_emails.size).to be(1)

    expect(current_email.subject).to end_with('Anne Other has not replied to your request for a reference')
  end

  def when_the_candidate_does_not_respond_within_16_days
    Timecop.travel(16.days.from_now) do
      ChaseReferences.perform_async
      ChaseReferences.perform_async
    end
  end

  def then_an_email_is_sent_to_the_candidate_asking_for_a_new_referee
    open_email(@application.candidate.email_address)

    expect(current_emails.size).to be(2)

    expect(current_email.subject).to have_content('Anne Other has not replied to your request for a reference')
  end

  def when_the_referee_does_not_respond_within_28_days
    Timecop.travel(28.days.from_now) do
      2.times { ChaseReferences.perform_async }
    end
  end

  def when_the_candidate_does_not_respond_within_30_days
    Timecop.travel(30.days.from_now) do
      ChaseReferences.perform_async
      ChaseReferences.perform_async
    end
  end

  def when_200_days_have_passed
    Timecop.travel(200.days.from_now) do
      ChaseReferences.perform_async
    end
  end

  def no_new_emails_have_been_sent
    open_email(@application.candidate.email_address)
    expect(current_emails.size).to be(3)
    open_email('anne@other.com')
    expect(current_emails.size).to be(3)
  end

  def then_the_candidate_is_sent_a_final_chase_email
    open_email(@application.candidate.email_address)
    expect(current_emails.size).to be(3)

    expect(current_email.subject).to have_content('Anne Other has not replied to your request for a reference')
  end

  def and_the_referee_is_sent_a_final_chase_email
    open_email('anne@other.com')

    expect(current_emails.size).to be(3)

    expect(current_email.subject).to have_content("Teacher training reference needed for #{@application.full_name}")
  end
end
