require 'rails_helper'

RSpec.feature 'An application gets declined by default' do
  include CourseOptionHelpers
  include CandidateHelper

  scenario 'before the DBD date the candidate receives a chaser email', sidekiq: true do
    given_the_pilot_is_open
    and_the_automated_candidate_chaser_is_active

    when_i_have_an_offer_waiting_for_my_decision
    and_the_time_limit_before_decline_by_default_date_has_been_exceeded
    then_i_receive_an_email_to_make_a_decision
  end

  def given_the_pilot_is_open
    FeatureFlag.activate('pilot_open')
  end

  def and_the_automated_candidate_chaser_is_active
    FeatureFlag.activate('automated_candidate_chaser')
  end

  def when_i_have_an_offer_waiting_for_my_decision
    @application_form = create(:completed_application_form)
    create(:application_choice, status: :offer, application_form: @application_form, decline_by_default_at: Time.zone.now + 10.days)
  end

  def and_the_time_limit_before_decline_by_default_date_has_been_exceeded
    time_limit_in_buiness_days = TimeLimitConfig.limits_for(:chase_candidate_before_dbd).first.limit
    decline_by_default_at = @application_form.application_choices.first.decline_by_default_at

    Timecop.travel(time_limit_in_buiness_days.days.before(decline_by_default_at)) do
      SendChaseEmailToCandidatesWorker.perform_async
    end
  end

  def then_i_receive_an_email_to_make_a_decision
    open_email(@application_form.candidate.email_address)

    expected_subject = I18n.t('chase_candidate_decision_email.subject_singular')
    expect(current_email.subject).to include(expected_subject)

    expect(current_email.body).to include('http://localhost:3000/candidate/sign-in')
  end
end
