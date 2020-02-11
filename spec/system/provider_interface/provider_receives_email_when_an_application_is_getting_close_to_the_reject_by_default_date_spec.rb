require 'rails_helper'

RSpec.feature 'An application is waiting for decision for 20 working days' do
  include CourseOptionHelpers
  include CandidateHelper

  scenario 'the provider receives a chaser email', sidekiq: true do
    FeatureFlag.activate('training_with_a_disability')
    FeatureFlag.activate('automated_provider_chaser')

    given_a_candidate_has_submitted_an_application_form
    and_an_application_was_sent_to_provider
    and_i_am_a_provider_user_at_the_course_provider

    when_the_application_is_getting_close_to_the_reject_by_default_date

    then_i_should_receive_a_chaser_email_with_a_link_to_the_application
  end

  def given_a_candidate_has_submitted_an_application_form
    candidate_completes_application_form
    candidate_submits_application
  end

  def and_an_application_was_sent_to_provider
    @submitted_application_choice = build(:submitted_application_choice)
    @application.application_choices << @submitted_application_choice
  end

  def and_i_am_a_provider_user_at_the_course_provider
    @provider_user = create(:provider_user)
    provider_id = @submitted_application_choice.provider.id
    create(:provider_users_provider, provider_id: provider_id, provider_user_id: @provider_user.id)
  end

  def when_the_application_is_getting_close_to_the_reject_by_default_date
    time_limit_in_buiness_days = TimeLimitConfig.limits_for(:chase_provider_before_rbd).first.limit
    Timecop.travel(time_limit_in_buiness_days.days.before(@submitted_application_choice.reject_by_default_at)) do
      SendChaseEmailToProvidersWorker.perform_async
    end
  end

  def then_i_should_receive_a_chaser_email_with_a_link_to_the_application
    open_email(@provider_user.email_address)

    expected_subject = I18n.t('provider_application_waiting_for_decision.email.subject', candidate_name: @application.full_name)
    expect(current_email.subject).to include(expected_subject)

    expect(current_email.body).to include("http://localhost:3000/provider/applications/#{@submitted_application_choice.id}")
  end
end
