class SaveProviderUser
  def initialize(provider_user:, permissions: {})
    @provider_user = provider_user
    @permissions = sanitized_permissions(permissions)
  end

  def call!
    @provider_user.save!
    update_permissions
    @provider_user.reload
  end

  def update_permissions
    ActiveRecord::Base.transaction do
      ProviderPermissions
        .where(provider_user: @provider_user)
        .update_all(ProviderPermissionsOptions.reset_attributes)

      @permissions.each do |permission, provider_ids|
        ProviderPermissions
          .where(provider_user: @provider_user, provider_id: provider_ids)
          .update_all(permission => true)
      end
    end
  end

  def sanitized_permissions(permissions)
    return {} unless @provider_user

    permissions.select do |permission_name, provider_ids|
      provider_ids.map!(&:to_i)
      ProviderPermissionsOptions.valid?(permission_name) &&
        (provider_ids & @provider_user.provider_ids) == provider_ids
    end
  end
end
