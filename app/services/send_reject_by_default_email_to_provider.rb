class SendRejectByDefaultEmailToProvider
  attr_accessor :application_choice

  def initialize(application_choice:)
    self.application_choice = application_choice
  end

  def call
    return false unless application_choice.rejected?

    NotificationsList.for(application_choice).each do |provider_user|
      ProviderMailer.application_rejected_by_default(provider_user, application_choice).deliver_later
      Metrics::Tracker.new(application_choice, 'notifications.on', provider_user).track(:application_rejected_by_default)
    end
    NotificationsList.off_for(application_choice).each do |provider_user|
      Metrics::Tracker.new(application_choice, 'notifications.off', provider_user).track(:application_rejected_by_default)
    end
  end
end
