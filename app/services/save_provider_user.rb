class SaveProviderUser
  attr_reader :provider_user, :provider_permissions, :deselected_provider_permissions

  def initialize(provider_user:, provider_permissions: [], deselected_provider_permissions: [])
    @provider_user = provider_user
    @provider_permissions = provider_permissions
    @deselected_provider_permissions = deselected_provider_permissions.select(&:persisted?)
  end

  def call!
    provider_user.save!
    save_notification_preferences!
    update_provider_permissions!
    send_emails_to_provider_user
    provider_user.reload
  end

private

  def save_notification_preferences!
    return if ProviderUserNotificationPreferences.exists?(provider_user: provider_user)

    ProviderUserNotificationPreferences.create!(provider_user: provider_user)
  end

  def update_provider_permissions!
    ActiveRecord::Base.transaction do
      destroy_deselected_provider_permissions!
      add_new_provider_permissions!
      updated_existing_provider_permissions!
    end
  end

  def destroy_deselected_provider_permissions!
    deselected_provider_permissions.each(&:destroy!)
  end

  def add_new_provider_permissions!
    new_provider_permissions.each do |provider_permissions|
      provider_permissions.provider_user_id ||= provider_user.id
      provider_permissions.save!
    end
  end

  def updated_existing_provider_permissions!
    existing_provider_permissions = provider_permissions & provider_user.provider_permissions
    existing_provider_permissions.each do |provider_permissions|
      provider_permissions.save! if provider_permissions.changed?
    end
  end

  def send_emails_to_provider_user
    send_permissions_granted_email
    send_permissions_removed_email
  end

  def send_permissions_granted_email
    new_provider_permissions.each do |new_permissions|
      ProviderMailer.permissions_granted(provider_user,
                                         new_permissions.provider,
                                         extract_permission_keys(new_permissions)).deliver_later
    end
  end

  def send_permissions_removed_email
    deselected_provider_permissions.each do |removed_permissions|
      ProviderMailer.permissions_removed(provider_user,
                                         removed_permissions.provider).deliver_later
    end
  end

  def new_provider_permissions
    @new_provider_permissions ||= provider_permissions - provider_user.provider_permissions
  end

  def extract_permission_keys(permissions)
    ProviderPermissions::VALID_PERMISSIONS.select { |permission| permissions.send(permission) }
  end
end
