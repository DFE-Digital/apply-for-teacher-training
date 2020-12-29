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

    if @application_choice.application_form.ended_without_success?
      CandidateMailer.withdraw_last_application_choice(@application_choice.application_form).deliver_later
    end

    StateChangeNotifier.call(:withdraw, application_choice: application_choice)
    send_email_notification_to_provider_users(application_choice)

    resolve_ucas_match(application_choice)
  end

private

  attr_reader :application_choice

  def send_email_notification_to_provider_users(application_choice)
    NotificationsList.for(application_choice).each do |provider_user|
      ProviderMailer.application_withdrawn(provider_user, application_choice).deliver_later
      Metrics::Tracker.new(application_choice, 'notifications.on', provider_user).track(:application_withdrawn)
    end
  end

  def resolve_ucas_match(application_choice)
    match = UCASMatches::RetrieveForApplicationChoice.new(application_choice).call

    if match && match.ready_to_resolve? && match.duplicate_applications_withdrawn_from_apply?
      UCASMatches::ResolveOnApply.new(match).call
    end
  end
end
