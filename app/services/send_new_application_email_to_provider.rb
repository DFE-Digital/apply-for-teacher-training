class SendNewApplicationEmailToProvider
  attr_accessor :application_choice

  def initialize(application_choice:)
    self.application_choice = application_choice
  end

  def call
    return false unless application_choice.awaiting_provider_decision?

    NotificationsList.for(application_choice).each do |provider_user|
      ProviderMailer.send(submission_type, provider_user, application_choice).deliver_later
      Metrics::Tracker.new(application_choice, 'notifications.on', provider_user).track(submission_type)
    end

    NotificationsList.off_for(application_choice).each do |provider_user|
      Metrics::Tracker.new(application_choice, 'notifications.off', provider_user).track(submission_type)
    end
  end

private

  def submission_type
    return :application_submitted unless application_choice.application_form.has_safeguarding_issues_to_declare?

    :application_submitted_with_safeguarding_issues
  end
end
