require 'rails_helper'

RSpec.feature 'Reject by default' do
  include CourseOptionHelpers

  scenario 'An application is rejected by default', with_audited: true do
    given_there_is_a_provider_user_for_the_provider_course
    and_the_provider_user_has_send_notifications_enabled
    and_there_is_a_candidate
    and_an_application_is_ready_to_reject_by_default

    when_the_application_is_getting_close_to_the_reject_by_default_date
    then_the_provider_should_receive_a_chaser_email_with_a_link_to_the_application

    when_the_application_is_rejected_by_default
    then_the_provider_should_receive_an_email
    and_the_candidate_should_receive_an_email
  end

  def given_there_is_a_provider_user_for_the_provider_course
    @course_option = course_option_for_provider_code(provider_code: 'ABC')
    @provider_user = Provider.find_by(code: 'ABC').provider_users.first
  end

  def and_the_provider_user_has_send_notifications_enabled
    @provider_user.update(send_notifications: true)
    create(:provider_user_notification_preferences, provider_user: @provider_user)
  end

  def and_there_is_a_candidate
    @candidate = create(:candidate)
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

  def then_the_provider_should_receive_a_chaser_email_with_a_link_to_the_application
    open_email(@provider_user.email_address)

    expected_subject = I18n.t(
      'provider_mailer.application_waiting_for_decision.subject',
      candidate_name: @application_choice.application_form.full_name,
      support_reference: @application_choice.application_form.support_reference,
    )
    expect(current_email.subject).to include(expected_subject)

    expect(current_email.body).to include(
      "http://localhost:3000/provider/applications/#{@application_choice.id}",
    )
  end

  def when_the_application_is_rejected_by_default
    RejectApplicationsByDefaultWorker.perform_async
  end

  def then_the_provider_should_receive_an_email
    open_email(@provider_user.email_address)

    expect(current_email.subject).to include(I18n.t!('provider_mailer.application_rejected_by_default.subject',
                                                     candidate_name: @application_choice.application_form.full_name,
                                                     support_reference: @application_choice.application_form.support_reference))
  end

  def and_the_candidate_should_receive_an_email
    open_email(@candidate.email_address)

    expect(current_email.subject).to include(I18n.t('candidate_mailer.application_rejected_all_applications_rejected.subject'))
  end
end
