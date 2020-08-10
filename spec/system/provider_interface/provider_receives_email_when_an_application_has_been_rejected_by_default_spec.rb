require 'rails_helper'

RSpec.feature 'An application has been rejected by default' do
  include CourseOptionHelpers

  scenario 'the provider receives a chaser email, provider and candidate both receive email when reject by default is triggered', with_audited: true do
    given_i_am_a_provider_user_with_a_provider
    and_there_is_a_candidate
    and_an_application_is_ready_to_reject_by_default

    when_the_application_is_getting_close_to_the_reject_by_default_date
    then_i_should_receive_a_chaser_email_with_a_link_to_the_application

    when_the_application_is_rejected_by_default
    then_i_should_receive_an_email
    and_the_candidate_should_receive_an_email
  end

  def given_i_am_a_provider_user_with_a_provider
    @course_option = course_option_for_provider_code(provider_code: 'ABC')
    @provider_user = Provider.find_by(code: 'ABC').provider_users.first
  end

  def and_there_is_a_candidate
    @candidate = create :candidate
  end

  def and_an_application_is_ready_to_reject_by_default
    @application_choice =
      create(
        :application_choice,
        status: 'awaiting_provider_decision',
        reject_by_default_at: Time.zone.today,
        course_option: @course_option,
        application_form:
          create(
            :completed_application_form,
            submitted_at: Time.zone.today,
            candidate: @candidate,
          ),
      )
  end

  def when_the_application_is_getting_close_to_the_reject_by_default_date
    time_limit_in_buiness_days = TimeLimitCalculator.new(rule: :chase_provider_before_rbd, effective_date: Time.zone.now).call[:days]
    Timecop.travel((time_limit_in_buiness_days.days - 1).before(@application_choice.reject_by_default_at)) do
      SendChaseEmailToProvidersWorker.perform_async
    end
  end

  def then_i_should_receive_a_chaser_email_with_a_link_to_the_application
    open_email(@provider_user.email_address)

    expected_subject = I18n.t(
      'provider_application_waiting_for_decision.email.subject',
      candidate_name: @application_choice.application_form.full_name,
    )
    expect(current_email.subject).to include(expected_subject)

    expect(current_email.body).to include(
      "http://localhost:3000/provider/applications/#{@application_choice.id}",
    )
  end

  def when_the_application_is_rejected_by_default
    RejectApplicationsByDefaultWorker.new.perform
  end

  def then_i_should_receive_an_email
    open_email(@provider_user.email_address)

    expect(current_email.subject).to include(t('provider_application_rejected_by_default.email.subject',
                                               candidate_name: @application_choice.application_form.full_name))
  end

  def and_the_candidate_should_receive_an_email
    open_email(@candidate.email_address)

    expect(current_email.subject).to include(
      t(
        'candidate_mailer.application_rejected_by_default.subject',
        provider_name: @application_choice.provider.name,
      ),
    )
  end
end
