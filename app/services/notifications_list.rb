class NotificationsList
  def self.for(application_choice, include_ratifying_provider: false)
    return application_choice.provider.provider_users.where(send_notifications: true) if application_choice.accredited_provider.nil? || !include_ratifying_provider

    application_choice.provider.provider_users.where(send_notifications: true).or(
      application_choice.accredited_provider.provider_users.where(send_notifications: true),
    )
  end
end
