class WithdrawApplication
  def initialize(application_choice:)
    @application_choice = application_choice
  end

  def save!
    ActiveRecord::Base.transaction do
      ApplicationStateChange.new(application_choice).withdraw!
      application_choice.update!(
        withdrawn_at: Time.zone.now,
        withdrawn_or_declined_for_candidate_by_provider: false,
      )
      application_choice.draft_withdrawal_reasons.each(&:publish!)
    end

    CancelUpcomingInterviews.new(
      actor: application_choice.candidate,
      application_choice:,
      cancellation_reason: I18n.t('interview_cancellation.reason.application_withdrawn'),
    ).call!

    if application_choice.application_form.ended_without_success?
      CandidateMailers::SendWithdrawnLastApplicationChoiceEmailWorker.perform_async(application_choice.application_form_id)
    end

    send_email_notification_to_provider_users
  end

private

  attr_reader :application_choice

  def send_email_notification_to_provider_users
    NotificationsList.for(application_choice, event: :application_withdrawn, include_ratifying_provider: true).each do |provider_user|
      ProviderMailer.application_withdrawn(provider_user, application_choice, number_of_cancelled_interviews).deliver_later
    end
  end

  def number_of_cancelled_interviews
    application_choice.interviews.kept.upcoming_not_today.count
  end
end
