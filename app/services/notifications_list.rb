class NotificationsList
  def self.for(application_choice)
    application_choice.provider.provider_users.where(send_notifications: true)
  end

  def self.off_for(application_choice)
    application_choice.provider.provider_users.where(send_notifications: false)
  end
end
