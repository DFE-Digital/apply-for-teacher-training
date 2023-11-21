# This file can be deleted with the continuous applications feature flag. The remaining functionality is tested in
# 'decline_by_default_spec.rb'

require 'rails_helper'

RSpec.feature 'Decline by default' do
  include CourseOptionHelpers
  include CandidateHelper

  scenario 'An application is declined by default', continuous_applications: false do
    when_i_have_an_offer_waiting_for_my_decision
    and_the_time_limit_before_decline_by_default_date_has_been_exceeded
    then_i_receive_an_email_to_make_a_decision

    and_when_the_decline_by_default_limit_has_been_exceeded
    then_the_application_choice_is_declined

    when_i_have_an_offer_waiting_for_my_decision
    and_i_have_a_rejection
    and_the_time_limit_before_decline_by_default_date_has_been_exceeded
    then_i_receive_an_email_to_make_a_decision

    and_when_the_decline_by_default_limit_has_been_exceeded
    then_the_application_choice_is_declined
  end

  def when_i_have_an_offer_waiting_for_my_decision
    @application_form = create(:completed_application_form, first_name: 'Harry', last_name: 'Potter')
    @application_choice = create(:application_choice, status: :offer, application_form: @application_form, sent_to_provider_at: Time.zone.now, decline_by_default_at: 10.days.from_now)

    @provider_user = create(:provider_user, :with_notifications_enabled, providers: [@application_choice.provider])
  end

  def and_the_time_limit_before_decline_by_default_date_has_been_exceeded
    time_limit_in_business_days = TimeLimitConfig.limits_for(:chase_candidate_before_dbd).first.limit
    decline_by_default_at = @application_form.application_choices.first.decline_by_default_at

    travel_temporarily_to(time_limit_in_business_days.days.before(decline_by_default_at)) do
      SendChaseEmailToCandidatesWorker.perform_async
    end
  end

  def then_i_receive_an_email_to_make_a_decision
    open_email(@application_form.candidate.email_address)

    expected_subject = I18n.t('candidate_mailer.chase_candidate_decision.subject_singular')
    expect(current_email.subject).to include(expected_subject)

    expect(current_email.body).to include('http://localhost:3000/candidate/sign-in/confirm')
  end

  def and_when_the_decline_by_default_limit_has_been_exceeded
    travel_temporarily_to(30.days.from_now) do
      DeclineOffersByDefaultWorker.perform_async
    end
  end

  def then_the_application_choice_is_declined
    @application_choice.reload

    expect(@application_choice.reload.status).to eql('declined')
  end

  def and_i_have_a_rejection
    create(:application_choice, status: :rejected, application_form: @application_form)
  end
end
