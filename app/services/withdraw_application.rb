class WithdrawApplication
  def initialize(application_choice:)
    @application_choice = application_choice
  end

  def save!
    ActiveRecord::Base.transaction do
      ApplicationStateChange.new(application_choice).withdraw!
      application_choice.update!(withdrawn_at: Time.zone.now)
      SetDeclineByDefault.new(application_form: application_choice.application_form).call
    end

    if FeatureFlag.active?(:cancel_upcoming_interviews_on_decision_made)
      number_of_cancelled_interviews = application_choice.interviews.kept.upcoming_not_today.count

      CancelUpcomingInterviews.new(
        actor: application_choice.candidate,
        application_choice: application_choice,
        cancellation_reason: I18n.t('interview_cancellation.reason.application_withdrawn'),
      ).call!
    else
      number_of_cancelled_interviews = 0
    end

    if @application_choice.application_form.ended_without_success?
      CandidateMailer.withdraw_last_application_choice(@application_choice.application_form).deliver_later
    end

    send_email_notification_to_provider_users(application_choice, number_of_cancelled_interviews)
  end

private

  attr_reader :application_choice

  def send_email_notification_to_provider_users(application_choice, number_of_cancelled_interviews)
    NotificationsList.for(application_choice, event: :application_withdrawn, include_ratifying_provider: true).each do |provider_user|
      ProviderMailer.application_withdrawn(provider_user, application_choice, number_of_cancelled_interviews).deliver_later
    end
  end
end
